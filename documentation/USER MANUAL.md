#  PetClinic Deployment — User Manual  
---

# 🚨 IMPORTANT — BEFORE YOU START  
### **You MUST rename the cloned folder to `task2`.**

If you clone directly as `DevOps-Task2-Giza`, the project **will not work**, because paths depend on:

```
/home/<user>/task2/
```

**Correct cloning command at HOME DIRECTORY:**

```bash
git clone https://github.com/wagiihh/DevOps-Task2-Giza.git task2
cd task2
```

---

# 🌟 1. What You Get After Deployment

You will end up with a full DevOps environment:

| Component | Purpose |
|----------|---------|
| **Tomcat 11** | Runs the PetClinic app (port 9090) |
| **Java 25** | Installed locally (user-mode, no sudo) |
| **Spring PetClinic App** | Automatically built & deployed |
| **Jenkins** | Portable CI/CD server (port 8081) |
| **Nagios Core** | Monitors Tomcat, Java process, and PetClinic |
| **Ansible Automation** | Orchestrates everything |

---

# 🧩 2. Requirements

You only need:

- Ubuntu machine (recommended)
- Python 3
- Git installed
- Ansible installed

Check Ansible:

```bash
ansible --version
```

If missing:

```bash
sudo apt install ansible -y
```

---

# 📁 3. Your Project Structure

```
task2/
 ├── ansible.cfg
 ├── deploy.yml
 ├── setup.yml
 ├── inventory
 ├── scripts/
 ├── roles/
 ├── templates/
 ├── builds/
 ├── src/
 └── Jenkinsfile
```

---

# 🧾 4. Configure Inventory

Open the file:

```
inventory
```

Default (for local machine):

```ini
[servers]
app01 ansible_host=127.0.0.1 ansible_user=pet-clinic ansible_ssh_pass=wigo123 ansible_become_pass=wigo123
```

If you run everything locally → no changes needed.

---

# 🔧 5. Step 1 — Install Tomcat + Jenkins + Nagios

Run:

```bash
ansible-playbook setup.yml
```

This installs:

- Tomcat (user-mode)
- Jenkins (portable, port 8081)
- Nagios Core (monitoring only)
- Required folder structure

No sudo. No apt. Everything inside your home.

---

# 🚀 6. Step 2 — Build & Deploy PetClinic

Now run:

```bash
ansible-playbook deploy.yml
```

This will automatically:

1. Install Java 25 locally  
2. Clone Spring PetClinic fresh  
3. Fix pom.xml + add ServletInitializer  
4. Build WAR  
5. Stop Tomcat  
6. Deploy new WAR  
7. Start Tomcat  
8. Health-check PetClinic until HTTP 200 👍  

If successful, you will see:

```
sanity.status: 200
```

🎉 **Application is live!**

---

# 🌐 7. Access Points

### ✔ PetClinic App  
```
http://127.0.0.1:9090/petclinic/
```

### ✔ Tomcat Manager  
```
http://127.0.0.1:9090/manager/html
```

Login:  
```
admin / admin123
```

### ✔ Jenkins (Portable)  
```
http://127.0.0.1:8081/
```

### ✔ Nagios Core  
Nagios runs locally (engine-only), logs here:  

```
~/nagios/var/nagios.log
```

---

# 🛠 8. Useful Commands

Restart Tomcat:

```bash
~/tomcat/bin/shutdown.sh
~/tomcat/bin/startup.sh
```

Restart Jenkins:

```bash
bash ~/jenkins/run_jenkins.sh
```

Check Nagios:

```bash
ps -ef | grep nagios
```

---

# ❗ 9. Common Issues (Friendly Fixes)

### Tomcat not starting?
```bash
pkill -f tomcat
rm -rf ~/tomcat
ansible-playbook setup.yml
```

### Build fails?
Delete old source:

```bash
rm -rf ~/task2/src/spring-petclinic
```

Redeploy:

```bash
ansible-playbook deploy.yml
```

---

# 🎉 10. You're Done!
You now have:

- Tomcat  
- Java 25  
- Jenkins  
- Nagios  
- Spring PetClinic  

All automated. All portable. No sudo required.  
Happy deploying! 🚀❤️
