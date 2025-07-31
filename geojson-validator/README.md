# Library to Validate GeoJSON Files

This Python library provides tools to validate GeoJSON files, ensuring that the geometries are correctly formatted and compliant with spatial standards.

---

## 📥 Download & Installation

### a) Clone the Repository

```sh
git clone https://github.com/KingTide/diasca-library.git
cd diasca-library
```

### b) Install Poetry (if not installed)

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

### c) Install Dependencies

```sh
poetry install
```

---

## 🛠 Development

### 1️⃣ Activate the Virtual Environment

Poetry 2.0.0 and later versions no longer include the `shell` command by default. Choose one of the following options:

#### **Option 1: Use the recommended `env activate` command**

```sh
poetry env use python
poetry env activate
```

To deactivate:

```sh
deactivate
```

#### **Option 2: Install the Poetry Shell Plugin (to use `poetry shell`)**

```sh
poetry self add "poetry-plugin-shell"
```

Then, activate the environment using:

```sh
poetry shell
```

---

### 2️⃣ Setting Up Pre-commit Hooks

To ensure **code quality**, we use pre-commit hooks that run automatically before each commit.

#### **Step 1: Install `pre-commit`**
```sh
poetry add --group dev pre-commit
```

#### **Step 2: Install Pre-commit Hooks**
```sh
poetry run pre-commit install
```

#### **Step 3: Manually Run Pre-commit Hooks**
To test the hooks on all files:

```sh
poetry run pre-commit run --all-files
```

---

### 3️⃣ Running Tests

If `pytest` is not found, ensure it is installed inside the Poetry environment:

```sh
poetry add --group dev pytest
```

Then, run tests using:

```sh
poetry run pytest
```

---

## 📜 Git Workflow

### ✅ Create a feature branch:
```sh
git checkout -b feature/new_feature
```

### ✅ Ensure formatting:
```sh
pre-commit run --all-files
```

### ✅ Run tests before committing:
```sh
pytest
```

### ✅ Commit the changes:
```sh
git commit -m "Add new feature"
```

### ✅ Push changes and open a PR:
```sh
git push origin feature/new_feature
```

---

## 🔧 Additional Commands

### ➕ Add a New Dependency

```sh
poetry add package_name
```

### ➕ Add a Development Dependency

```sh
poetry add --group dev package_name
```

### ▶️ Run Scripts Inside the Virtual Environment

```sh
poetry run python script.py
```

### ℹ️ Check the Virtual Environment Info

```sh
poetry env info
```

### ❌ Deactivate the Virtual Environment

```sh
deactivate
```

---

## 📄 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.
