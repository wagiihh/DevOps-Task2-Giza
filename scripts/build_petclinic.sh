#!/bin/bash
set -euo pipefail

echo "[INFO] === Installing Local JDK 25 (User-Mode) ==="

JDK_DIR="$HOME/java"
JDK_VERSION="25.0.1"
JDK_TAR="jdk-${JDK_VERSION}_linux-aarch64_bin.tar.gz"
JDK_URL="https://download.oracle.com/java/25/latest/$JDK_TAR"

mkdir -p "$JDK_DIR"

# ---------------------------------------------
# Install JDK only once
# ---------------------------------------------
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

echo "[INFO] Using Java:"
java -version


# ========================================================================
# Folder structure
# ========================================================================
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_ROOT="$ROOT_DIR/src"
SRC_DIR="$SRC_ROOT/spring-petclinic"
BUILD_DIR="$ROOT_DIR/builds"
WAR_NAME="petclinic.war"

echo "[INFO] Ensuring directories exist"
mkdir -p "$SRC_ROOT" "$BUILD_DIR"


# ========================================================================
# Clone or update PetClinic
# ========================================================================
if [ ! -d "$SRC_DIR/.git" ]; then
  echo "[INFO] Cloning spring-petclinic"
  git clone --depth 1 https://github.com/spring-projects/spring-petclinic.git "$SRC_DIR"
else
  echo "[INFO] Updating spring-petclinic"
  git -C "$SRC_DIR" fetch --depth 1 origin main
  git -C "$SRC_DIR" reset --hard origin/main
fi

cd "$SRC_DIR"


# ========================================================================
# Force WAR Packaging + Disable Spring Formatter Plugin
# ========================================================================
echo "[INFO] Forcing WAR packaging and disabling formatter"

python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET

pom = Path("pom.xml")
ns = {"m": "http://maven.apache.org/POM/4.0.0"}
ET.register_namespace("", ns["m"])
tree = ET.parse(pom)
root = tree.getroot()

# --- Force <packaging>war</packaging> ---
pack = root.find("m:packaging", ns)
if pack is None:
    pack = ET.SubElement(root, "{http://maven.apache.org/POM/4.0.0}packaging")
pack.text = "war"

# --- Ensure build/plugins exist ---
build = root.find("m:build", ns)
if build is None:
    build = ET.SubElement(root, "{http://maven.apache.org/POM/4.0.0}build")

plugins = build.find("m:plugins", ns)
if plugins is None:
    plugins = ET.SubElement(build, "{http://maven.apache.org/POM/4.0.0}plugins")

# --- Remove spring-javaformat plugin to avoid build failure ---
for plugin in plugins.findall("m:plugin", ns):
    gid = plugin.find("m:groupId", ns)
    aid = plugin.find("m:artifactId", ns)
    if gid is not None and aid is not None:
        if gid.text == "io.spring.javaformat" and aid.text == "spring-javaformat-maven-plugin":
            plugins.remove(plugin)
            break

pom.write_text(ET.tostring(root, encoding="unicode"))
PY


# ========================================================================
# Copy ServletInitializer
# ========================================================================
echo "[INFO] Adding ServletInitializer"

TARGET_JAVA_DIR="$SRC_DIR/src/main/java/org/springframework/samples/petclinic"
mkdir -p "$TARGET_JAVA_DIR"

cp -f "$HOME/templates/ServletInitializer.java" "$TARGET_JAVA_DIR/ServletInitializer.java"


# ========================================================================
# Build WAR
# ========================================================================
echo "[INFO] Building WAR (tests skipped)"
chmod +x ./mvnw

# Run Maven with JAVA_HOME
JAVA_HOME="$JAVA_HOME" ./mvnw clean package -DskipTests

echo "[INFO] Copying WAR artifact"
cp target/*.war "$BUILD_DIR/$WAR_NAME"

echo "[INFO] DONE! WAR ready at: $BUILD_DIR/$WAR_NAME"
