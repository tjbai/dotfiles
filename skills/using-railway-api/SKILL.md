---
name: using-railway-api
description: "Uses Railway's GraphQL API safely with RAILWAY_API_TOKEN, especially project-scoped tokens. Use when automating Railway deployments, services, variables, environments, or replacing Railway CLI commands in CI."
---

# Using Railway API

Use Railway's public GraphQL API for non-interactive automation. Do not assume `RAILWAY_API_TOKEN` is an account-wide token: it may be a project token scoped to one project environment.

## Token headers

Railway has different API token types with different headers:

- Account, workspace, and OAuth tokens use `Authorization: Bearer $RAILWAY_API_TOKEN`.
- Project tokens use `Project-Access-Token: $RAILWAY_API_TOKEN`.

If a token came from a Railway project settings page, treat it as a project token first. Verify it with:

```bash
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header "Project-Access-Token: $RAILWAY_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"query":"query { projectToken { projectId environmentId } }"}'
```

For account/workspace tokens, a basic bearer-token check is:

```bash
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header "Authorization: Bearer $RAILWAY_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"query":"query { me { id name email } }"}'
```

`me` is not valid for project tokens. A `Not Authorized` response there does not mean the project token is unusable.

## Avoid global and interactive CLI commands in CI

With project-scoped tokens, avoid Railway CLI commands that need account/workspace-wide discovery or interactive state, including:

- `railway project list`
- `railway link`
- `railway login`
- interactive `railway add` flows

Prefer GraphQL requests that use known IDs. Get project, environment, and service IDs from configuration, Railway dashboard command palette, prior script output, or `projectToken { projectId environmentId }` for project tokens.

## Query a known project by ID

When using an account or workspace token, query the known project directly instead of listing all projects:

```bash
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header "Authorization: Bearer $RAILWAY_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data @- <<'JSON'
{
  "query": "query project($id: String!) { project(id: $id) { id name services { edges { node { id name } } } } }",
  "variables": { "id": "PROJECT_ID" }
}
JSON
```

If the only available credential is a project token, first check `projectToken { projectId environmentId }`, then attempt only project/environment-scoped operations supported by that token. Do not fall back to global listing commands.

## Create services with GraphQL mutations

Replace interactive service creation with `serviceCreate`:

```bash
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header "Authorization: Bearer $RAILWAY_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data @- <<'JSON'
{
  "query": "mutation serviceCreate($input: ServiceCreateInput!) { serviceCreate(input: $input) { id name } }",
  "variables": {
    "input": {
      "projectId": "PROJECT_ID",
      "name": "Backend API"
    }
  }
}
JSON
```

For GitHub-backed services, include `source.repo` and optionally `branch`:

```json
{
  "input": {
    "projectId": "PROJECT_ID",
    "name": "My API",
    "source": { "repo": "owner/repo" },
    "branch": "main"
  }
}
```

For image-backed services, use `source.image`:

```json
{
  "input": {
    "projectId": "PROJECT_ID",
    "name": "Redis",
    "source": { "image": "redis:7-alpine" }
  }
}
```

If a project token is the only token available, send the same mutation with `Project-Access-Token` and the known project ID. If Railway returns unauthorized, the fix is to use a workspace/account token with sufficient permissions or create the service manually, not to add `railway link` or `project list` back into CI.

## Debugging rules

- Inspect GraphQL `errors[].message` before changing the script.
- Use `https://backboard.railway.com/graphql/v2`, not old `.app` endpoints unless a local script is already known to require it.
- Use Railway GraphiQL or schema introspection to confirm field and input names before guessing.
- Keep tokens out of logs. Print token type, project ID, environment ID, and operation names instead.
- If a CLI command works locally but fails in CI with `Unauthorized`, check whether CI has a project token and replace global CLI discovery with ID-based GraphQL.
