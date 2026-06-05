# How to Use This Repo

Follow this workflow for every lab.

---

## Lab workflow

1. **Create or confirm your kind cluster is running**

   ```bash
   kind get clusters
   kubectl config current-context
   ```

   If the cluster does not exist:

   ```bash
   kind create cluster --config 00-kind-cluster/kind-config.yaml
   ```

2. **Enter the lab folder**

   ```bash
   cd 01-pods
   ```

3. **Read `README.md`**

   Understand the goal, what you will build, and the success criteria before running any command.

4. **Apply manifests or run commands**

   Follow the steps in `README.md`. Open `commands.md` for the ordered command list.

5. **Observe outputs**

   Read every line of output. Do not move on until you understand what each command returned.

6. **Answer `notes.md`**

   Open `notes.md` and write your answers in your own words. Do not copy from `solutions.md`. This is your personal learning record.

7. **Run the break/fix section**

   Apply the broken manifests from `broken/`. Diagnose the failure. Fix it. Write down what you found.

8. **Check `solutions.md` only after attempting**

   Compare your observations and explanations to the solutions. Note anything you missed.

9. **Run `cleanup.sh`**

   ```bash
   ./cleanup.sh
   ```

   Every lab has a cleanup script that removes only the resources that lab created.

10. **Commit your personal notes if using a private fork**

    If you have forked this repo, commit your `notes.md` answers to track your progress.

---

## Important rule

**Do not memorize commands blindly.**

For every command you run, write down:
- What object or resource it inspected or changed
- What the output told you
- What question it answered

Commands without understanding are noise. Understanding without commands is theory. You need both.

---

## Before sharing or publishing

If you have written personal answers in `notes.md` files and want to share or publish a clean version:

```bash
./scripts/reset-notes.sh
```

Or with no confirmation prompt:

```bash
./scripts/reset-notes.sh --yes
```

This replaces all `notes.md` files with blank templates. It does not touch `solutions.md`, `README.md`, or any manifests.

---

## Lab 09 note

Lab `09-network-policies` uses its own separate kind cluster named `netpol-lab`. Read the lab README before starting it. The cleanup script for that lab deletes only that cluster.

---

## If you get stuck

1. `kubectl describe <resource> <name> -n <namespace>` — always read the Events section
2. `kubectl get events -n <namespace>` — see all recent events in the namespace
3. `kubectl logs <pod> -n <namespace>` — check what the container is printing
4. Check `solutions.md` for hints after you have genuinely attempted the diagnosis

The goal is not to complete labs quickly. The goal is to be able to operate Kubernetes under pressure without looking things up.
