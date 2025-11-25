#!/bin/bash
set -euo pipefail

echo "[INFO] === Installing Local JDK 25 (User-Mode) ==="

JDK_DIR="$HOME/java"
JDK_VERSION="25.0.1"
JDK_TAR="jdk-${JDK_VERSION}_linux-aarch64_bin.tar.gz"
JDK_URL="https://download.oracle.com/java/25/latest/$JDK_TAR"

mkdir -p "$JDK_DIR"

# -----------------------------------------------------
# Install JDK 25 ONLY ONCE (your original logic kept)
# -----------------------------------------------------
if [ ! -d "$JDK_DIR/jdk-$JDK_VERSION" ]; then
  echo "[INFO] Downloading JDK 25..."
  curl -fsSL "$JDK_URL" -o "/tmp/$JDK_TAR"

  echo "[INFO] Extracting JDK 25..."
  tar -xzf "/tmp/$JDK_TAR" -C "$JDK_DIR"
else
  echo "[INFO] JDK 25 already installed."
fi

export JAVA_HOME="$JDK_DIR/jdk-$JDK_VERSION"
export PATH="$JAVA_HOME/bin:$PATH"

echo "[INFO] Using Java version:"
java -version


# ========================================================================
# FIXED: Correct folder structure (NO MORE .ansible/tmp ISSUE)
# ========================================================================
# Ansible will run this script with:
#   chdir: /home/wagih/task2
# So we MUST use $PWD, otherwise BASH_SOURCE points to ~/.ansible/tmp
ROOT_DIR="/home/wagih/task2"
SRC_ROOT="$ROOT_DIR/src"
SRC_DIR="$SRC_ROOT/spring-petclinic"
BUILD_DIR="$ROOT_DIR/builds"
WAR_NAME="petclinic.war"

echo "[INFO] ROOT_DIR = $ROOT_DIR"
echo "[INFO] SRC_DIR  = $SRC_DIR"
echo "[INFO] BUILD_DIR = $BUILD_DIR"

mkdir -p "$SRC_ROOT" "$BUILD_DIR"


# ========================================================================
# Clone OR update PetClinic repository (your logic preserved)
# ========================================================================
if [ ! -d "$SRC_DIR/.git" ]; then
  echo "[INFO] Cloning spring-petclinic..."
  git clone --depth 1 https://github.com/spring-projects/spring-petclinic.git "$SRC_DIR"
else
  echo "[INFO] Updating spring-petclinic..."
  git -C "$SRC_DIR" fetch --depth 1 origin main
  git -C "$SRC_DIR" reset --hard origin/main
fi

cd "$SRC_DIR"


# ========================================================================
# Force WAR packaging + Remove broken plugins (your logic)
# ========================================================================
echo "[INFO] Forcing WAR packaging and cleaning POM..."

python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET

pom = Path("pom.xml")
ns = {"m": "http://maven.apache.org/POM/4.0.0"}
ET.register_namespace("", ns["m"])
tree = ET.parse(pom)
root = tree.getroot()

# Force <packaging>war</packaging>
pack = root.find("m:packaging", ns)
if pack is None:
    pack = ET.SubElement(root, "{http://maven.apache.org/POM/4.0.0}packaging")
pack.text = "war"

# Remove spring-javaformat plugin which breaks WAR build
build = root.find("m:build", ns)
if build is None:
    build = ET.SubElement(root, "{http://maven.apache.org/POM/4.0.0}build")

plugins = build.find("m:plugins", ns)
if plugins is None:
    plugins = ET.SubElement(build, "{http://maven.apache.org/POM/4.0.0}plugins")

for p in plugins.findall("m:plugin", ns):
    gid = p.find("m:groupId", ns)
    aid = p.find("m:artifactId", ns)
    if gid is not None and aid is not None:
        if gid.text == "io.spring.javaformat" and aid.text == "spring-javaformat-maven-plugin":
            plugins.remove(p)

pom.write_text(ET.tostring(root, encoding="unicode"))
PY


# ========================================================================
# Copy Your ServletInitializer (correct package path)
# ========================================================================
echo "[INFO] Adding ServletInitializer.java..."

TARGET_JAVA_DIR="$SRC_DIR/src/main/java/org/springframework/samples/petclinic"
mkdir -p "$TARGET_JAVA_DIR"

cp -f "$HOME/templates/ServletInitializer.java" "$TARGET_JAVA_DIR/ServletInitializer.java"


# ========================================================================
# Build WAR using Maven Wrapper + Java 25
# ========================================================================
echo "[INFO] Building PetClinic WAR..."
chmod +x ./mvnw

JAVA_HOME="$JAVA_HOME" ./mvnw clean package -DskipTests


# ========================================================================
# Copy WAR to builds directory (THIS is what deploy.yml needs)
# ========================================================================
echo "[INFO] Copying WAR → $BUILD_DIR/$WAR_NAME"

cp target/*.war "$BUILD_DIR/$WAR_NAME"

echo "[INFO] ========================================="
echo "[INFO]  WAR READY: $BUILD_DIR/$WAR_NAME"
echo "[INFO] ========================================="
