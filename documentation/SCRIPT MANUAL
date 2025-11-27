
# 🛠 PetClinic DevOps — Script & Role Manual  
*A friendly guide for developers & maintainers*

---

# 🚨 IMPORTANT  
### **You MUST rename the cloned folder to `task2`.**

Many paths depend on:

```
/home/<user>/task2/
```

Correct cloning command:

```bash
git clone https://github.com/wagiihh/DevOps-Task2-Giza.git task2
```

---

# 📁 1. Repo Structure (Developer View)

```
task2/
 ├── ansible.cfg  
 ├── inventory  
 ├── setup.yml  
 ├── deploy.yml  
 ├── scripts/  
 ├── roles/  
 ├── templates/  
 ├── builds/  
 ├── src/  
 └── Jenkinsfile
```

---

# 📘 2. Playbooks

## 🎬 setup.yml  
Installs:
- Tomcat  
- Jenkins  
- Nagios  

Runs roles in this order:

```yaml
roles:
  - tomcat
  - jenkins
  - nagios
```

---

## 🚀 deploy.yml  

Builds & deploys PetClinic:

1. Runs `scripts/build_petclinic.sh`
2. Stops Tomcat  
3. Removes old WAR  
4. Copies new WAR  
5. Starts Tomcat  
6. Health-checks the app  

If HTTP 200 → deployment successful.

---

# 🧩 3. Roles

## 🟦 roles/tomcat
- Creates `~/tomcat`
- Downloads Tomcat 11.0.1  
- Extracts portable version  
- Changes port → **9090**
- Enables WAR autodeploy  
- Adds admin user  
- Creates Java 25 `setenv.sh`
- Starts Tomcat  

---

## 🟧 roles/jenkins
Portable Jenkins:

- Installs into `~/jenkins`
- Downloads WAR  
- Creates `run_jenkins.sh`  
- Starts Jenkins on port **8081**

---

## 🟥 roles/nagios
User-mode Nagios install:

- Builds Nagios Core from source  
- Removes all default configs  
- Adds custom checks:  
  - check_process  
  - check_port  
  - check_http_custom  
- Adds services for:
  - Java  
  - Port 9090  
  - Tomcat page  
  - PetClinic page  
- Runs Nagios engine via script  

---

# 🧪 4. Scripts

## build_petclinic.sh  
Handles:
- Install Java 25  
- Clone PetClinic  
- Fix pom.xml (WAR)  
- Add ServletInitializer  
- Build WAR via Maven Wrapper  
- Save war to `builds/petclinic.war`

## build_nagios.sh  
Builds Nagios from source:
- Downloads tar.gz  
- Configures  
- make + make install  
- Creates cfg_dir  

---

# 🔧 5. Jenkins Pipeline

Stages:
1. cleanWs()  
2. checkout scm  
3. build WAR  
4. stop Tomcat  
5. deploy WAR  
6. restart Tomcat  
7. success message  

---

# 🔄 6. Full System Workflow

```
setup.yml
   ↓ installs Tomcat/Jenkins/Nagios
deploy.yml
   ↓ builds PetClinic (build_petclinic.sh)
   ↓ deploys WAR to Tomcat
Nagios
   ↓ monitors system & app
Jenkins
   ↓ can automate deployments
```

---

# 🎉 7. Final Notes

- Everything is portable  
- No root required  
- Easy to extend (add roles, add scripts)  
- Safe to re-run  

Happy automating! 🚀
