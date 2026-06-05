# Lab 27 — Notes Workbook

Answer each question before checking solutions.md.

---

### Question 1
`kubectl get endpoints -n lab-27-network` shows `<none>` for backend-svc. What does this mean, and what are two possible reasons for it?

Write your answer here.

---

### Question 2
How do you compare a service's selector to the labels on pods without looking at either YAML file directly? Write the two kubectl commands you would use.

Write your answer here.

---

### Question 3
backend-svc has no endpoints (selector typo) and backend-port-svc has endpoints but the connection is refused (wrong targetPort). What is the error behaviour of each from a client's perspective, and how are they different?

Write your answer here.

---

### Question 4
What does `targetPort` mean in a Service spec? How is it different from `port`?

Write your answer here.

---

### Question 5
You run `kubectl patch svc backend-svc -n lab-27-network -p '{"spec":{"selector":{"app":"backend"}}}'`. Explain what this command does without deleting the service.

Write your answer here.

---

### Question 6
Write out the three DNS name forms for a service named `backend-svc` in namespace `lab-27-network`. Which form works when the client is in a different namespace?

Write your answer here.

---

### Question 7
wrong-dns-client tries to reach `http://backend`. Explain exactly why this DNS name fails even though backend-svc exists in the same namespace.

Write your answer here.

---

### Question 8
How do you diagnose a DNS name failure from inside a pod? Write the exact command you would run first.

Write your answer here.

---

### Question 9
A service has correct endpoints (pods are matched) and the targetPort is correct, but clients still cannot connect. Name two other possible causes.

Write your answer here.

---

### Question 10
Summarise the diagnostic steps for each of the three networking problems in this lab. For each, write: the symptom, the first command to run, and what the output shows.

Write your answer here.
