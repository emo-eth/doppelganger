Forge-Template

Minimal template for Forge projects.

Minor tweaks include
- Updated `.gitignore` to include
  - all files starging with `.`
  - the `broadcast` directory (for better or worse)
  - `lcov.info` and the `html` folder associated with local coverage reports
- Includes (this) `README.md` file
- Includes `.vscode` directory that specifies `forge` as the default formatter
- `.github/test.yml` is configured to run `forge test` on push and pull requests, not just dispatch
