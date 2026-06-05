# Lab 26 — Notes Workbook

Answer each question before checking solutions.md.

---

### Scenario 1 — app-01

**Q1:** What is the exact image tag that caused the failure, and how did you find it from kubectl output (not from the YAML file)?

Write your answer here.

---

**Q2:** What is the difference between `ErrImagePull` and `ImagePullBackOff`? Are they different problems or different stages of the same problem?

Write your answer here.

---

**Q3:** What did `kubectl rollout status deployment/app-01` show while the deployment was broken? What did it show after the fix?

Write your answer here.

---

### Scenario 2 — app-02

**Q4:** What was the last line printed to stdout before the container exited? What exit code was returned?

Write your answer here.

---

**Q5:** Why did the shell command `cat /etc/nonexistent/config.json` cause the entire container to exit rather than just printing an error?

Write your answer here.

---

**Q6:** How is the output of `kubectl logs --previous` different from `kubectl logs` for a pod in CrashLoopBackOff? When would the two commands show different content?

Write your answer here.

---

### Scenario 3 — app-03

**Q7:** The pod for app-03 showed a growing RESTARTS count but the STATUS was initially `Running`. How did you determine the container was being killed by the liveness probe and not crashing on its own?

Write your answer here.

---

**Q8:** What does exit code 137 mean, and how is it different from exit code 1?

Write your answer here.

---

**Q9:** What single field in the liveness probe spec was wrong, and what was the correct value?

Write your answer here.

---

### Scenario 4 — app-04

**Q10:** What resources did the pod request, and why did those values prevent it from scheduling on any node in the kind cluster?

Write your answer here.

---

**Q11:** A pod is in `Pending`. Name three different root causes that could cause this besides excessive resource requests.

Write your answer here.

---

**Q12:** Is `kubectl rollout status` useful for debugging a Pending pod? What does it show?

Write your answer here.

---

### General

**Q13:** In what order would you run the following commands when triaging an unknown broken deployment? Explain your reasoning.
- `kubectl rollout status deployment/<name>`
- `kubectl get pods -n <ns>`
- `kubectl logs <pod> --previous`
- `kubectl describe pod <pod>`

Write your answer here.

---

**Q14:** When is `kubectl edit` a good way to fix a deployment vs when should you apply a fixed YAML file instead?

Write your answer here.
