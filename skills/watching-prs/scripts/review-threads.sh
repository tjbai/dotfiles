#!/usr/bin/env bash
set -euo pipefail

pr="${1:?usage: review-threads.sh <PR number, URL, or branch>}"
meta="$(gh pr view "$pr" --json url,number,headRefOid)"
url="$(jq -r '.url' <<<"$meta")"
host="$(jq -r '.url | split("/")[2]' <<<"$meta")"
owner="$(jq -r '.url | split("/")[3]' <<<"$meta")"
repo="$(jq -r '.url | split("/")[4]' <<<"$meta")"
number="$(jq -r '.number' <<<"$meta")"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
jq -n --argjson pullRequest "$meta" '{pullRequest:$pullRequest,threads:[]}' >"$tmp/result.json"

threads_query='query($owner:String!,$repo:String!,$number:Int!,$after:String){repository(owner:$owner,name:$repo){pullRequest(number:$number){reviewThreads(first:100,after:$after){nodes{id isResolved isOutdated path line originalLine startLine originalStartLine diffSide comments(first:100){nodes{id databaseId body url createdAt updatedAt viewerDidAuthor author{login} replyTo{id} pullRequestReview{id state submittedAt author{login}}} pageInfo{hasNextPage endCursor}}} pageInfo{hasNextPage endCursor}}}}}'
comments_query='query($id:ID!,$after:String!){node(id:$id){... on PullRequestReviewThread{comments(first:100,after:$after){nodes{id databaseId body url createdAt updatedAt viewerDidAuthor author{login} replyTo{id} pullRequestReview{id state submittedAt author{login}}} pageInfo{hasNextPage endCursor}}}}}'

after=""
while true; do
  args=(api graphql --hostname "$host" -f query="$threads_query" -F owner="$owner" -F repo="$repo" -F number="$number")
  [[ -n "$after" ]] && args+=(-f after="$after")
  gh "${args[@]}" >"$tmp/page.json"
  jq '.data.repository.pullRequest.reviewThreads.nodes' "$tmp/page.json" >"$tmp/nodes.json"
  jq --slurpfile nodes "$tmp/nodes.json" '.threads += $nodes[0]' "$tmp/result.json" >"$tmp/next.json"
  mv "$tmp/next.json" "$tmp/result.json"
  [[ "$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' "$tmp/page.json")" == "true" ]] || break
  after="$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor' "$tmp/page.json")"
done

while IFS=$'\t' read -r id after; do
  while [[ -n "$after" && "$after" != "null" ]]; do
    gh api graphql --hostname "$host" -f query="$comments_query" -F id="$id" -f after="$after" >"$tmp/comments.json"
    jq --arg id "$id" --slurpfile page "$tmp/comments.json" '
      ($page[0].data.node.comments) as $comments
      | .threads |= map(if .id == $id then .comments.nodes += $comments.nodes | .comments.pageInfo = $comments.pageInfo else . end)
    ' "$tmp/result.json" >"$tmp/next.json"
    mv "$tmp/next.json" "$tmp/result.json"
    if [[ "$(jq -r '.data.node.comments.pageInfo.hasNextPage' "$tmp/comments.json")" == "true" ]]; then
      after="$(jq -r '.data.node.comments.pageInfo.endCursor' "$tmp/comments.json")"
    else
      after=""
    fi
  done
done < <(jq -r '.threads[] | select(.comments.pageInfo.hasNextPage) | [.id,.comments.pageInfo.endCursor] | @tsv' "$tmp/result.json")

jq . "$tmp/result.json"
