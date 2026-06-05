# Lab 25 — Notes Workbook

Answer each question in your own words. Do not look at solutions.md until you have written an attempt.

---

### Question 1
List the five pod failure states you observed in this lab. For each state, write the single kubectl command that was most useful for finding the root cause.

Write your answer here.

---

### Question 2
What is the difference between `kubectl logs <pod>` and `kubectl describe pod <pod>`? When would you use each one?

Write your answer here.

---

### Question 3
What does the **Events** section in `kubectl describe` show you that `kubectl logs` cannot show?

Write your answer here.

---

### Question 4
A pod is in `ImagePullBackOff`. What does `kubectl describe pod` show in its Events section that identifies the exact problem?

Write your answer here.

---

### Question 5
A pod is in `CreateContainerConfigError`. What does `kubectl describe pod` show, and why does `kubectl logs` return nothing?

Write your answer here.

---

### Question 6
What does `kubectl logs --previous` do? In what situation is it the only way to see useful diagnostic information?

Write your answer here.

---

### Question 7
`kubectl get endpoints broken-svc -n lab-25-observe` shows `<none>`. What does this mean, and how do you find the cause without looking at the service YAML directly?

Write your answer here.

---

### Question 8
What is the difference between `kubectl get events` and the Events section inside `kubectl describe pod`? When would you prefer the events command over describe?

Write your answer here.

---

### Question 9
You run `kubectl get events -n lab-25-observe --sort-by=.metadata.creationTimestamp`. What ordering does this give you, and why is that useful during an incident?

Write your answer here.

---

### Question 10
A pod shows `Pending` in `kubectl get pods`. What is the first command you run, and what are the two most common reasons a pod stays Pending?

Write your answer here.

---

### Question 11
You want to run a quick command inside a running nginx pod to check which version of nginx is installed. Write the exact kubectl command to do this (use any valid pod name format).

Write your answer here.

---

### Question 12
How do `kubectl logs -l app=working-app` and `kubectl logs <specific-pod-name>` differ in their output?

Write your answer here.
