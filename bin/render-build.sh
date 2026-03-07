#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
bundle exec rails db:seed
```

Click **"Commit changes"** at the bottom.

---

## Then Trigger a New Deploy

Go to Render → **Manual Deploy** → **Deploy latest commit**

This time the migration runs as part of the build process — no shell, no paid plan needed.

---

## What Success Looks Like in the Logs

You'll see this during the build phase (before "Puma starting"):
```
== AddTestTypeToInputs: migrating ======
-- add_column(:inputs, :test_type...)
== AddTestTypeToInputs: migrated ✅
Seeding engine config baselines...
Done!
