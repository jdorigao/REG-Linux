import json
import logging
from pathlib import Path
from configparser import ConfigParser
from io import StringIO
from typing import Any, Optional, Union, Dict


# ========= JSON Settings =========
class JSONSettings:
    """
    JSON-based configuration manager with automatic file creation support.

    This class provides an interface for reading, writing, and managing
    JSON configuration files. If the file does not exist, it will be created
    automatically with an empty JSON object (`{}`).

    Example:
        settings = JSONSettings("config.json")
        settings.save("username", "admin")
        settings.write()
    """

    __slots__ = ("filepath", "_data", "_logger")

    def __init__(self, filepath: str | Path, auto_load: bool = True) -> None:
        """
        Initialize the JSONSettings object.

        Args:
            filepath (str | Path): Path to the JSON configuration file.
            auto_load (bool): If True, automatically load the file into memory.
        """
        self.filepath = Path(filepath)
        self._data: dict[str, Any] = {}
        self._logger = logging.getLogger(f"{__name__}.JSONSettings")
        if auto_load:
            self.load()

    def _ensure_file_exists(self) -> None:
        """
        Ensure the JSON file exists. If not, create an empty one.
        """
        if not self.filepath.exists():
            try:
                self.filepath.parent.mkdir(parents=True, exist_ok=True)
                self.filepath.write_text("{}", encoding="utf-8")
                self._logger.info(f"Created new JSON file: {self.filepath}")
            except Exception as e:
                self._logger.error(f"Failed to create JSON file {self.filepath}: {e}")

    def load(self, default: Optional[dict[str, Any]] = None) -> dict[str, Any]:
        """
        Load the JSON configuration into memory.

        Args:
            default (dict | None): Fallback dictionary if loading fails.

        Returns:
            dict: The loaded configuration dictionary.
        """
        self._ensure_file_exists()
        try:
            with self.filepath.open("r", encoding="utf-8") as f:
                self._data = json.load(f)
        except Exception as e:
            self._logger.error(f"Failed to load JSON {self.filepath}: {e}")
            self._data = default or {}
        return self._data

    def write(self, indent: int = 4) -> bool:
        """
        Write the in-memory configuration to disk.

        Args:
            indent (int): Number of spaces used for indentation.

        Returns:
            bool: True if successful, False otherwise.
        """
        try:
            with self.filepath.open("w", encoding="utf-8") as f:
                json.dump(self._data, f, indent=indent, ensure_ascii=False)
            return True
        except Exception as e:
            self._logger.error(f"Failed to write JSON {self.filepath}: {e}")
            return False

    def save(self, name: str, value: Any) -> None:
        """
        Save a key-value pair in memory.
        Note: Call `write()` to persist changes to disk.
        """
        self._data[name] = value

    def remove(self, name: str) -> bool:
        """
        Remove a key from the configuration.

        Returns:
            bool: True if the key was removed, False otherwise.
        """
        return self._data.pop(name, None) is not None

    def exists(self, name: str) -> bool:
        """
        Check if a key exists in the configuration.
        """
        return name in self._data

    def get(self, name: str, default: Optional[Any] = None) -> Optional[Any]:
        """
        Retrieve a value by key.

        Args:
            name (str): Key name.
            default (Any | None): Value to return if key is missing.

        Returns:
            Any: The stored value or the default.
        """
        return self._data.get(name, default)

    def loadAll(self, name: str, includeName: bool = False) -> Dict[str, str]:
        """
        Load all keys that start with a given prefix.

        Args:
            name (str): Prefix to search for.
            includeName (bool): If True, include the full key name.
                                Otherwise, return only the suffix.

        Returns:
            dict: Dictionary of matching key-value pairs.
        """
        result = {}
        for key, value in self._data.items():
            if key.startswith(name + "."):
                suffix = key if includeName else key[len(name) + 1 :]
                result[suffix] = value
        return result

    # Enable dictionary-like access
    def __getitem__(self, name: str) -> Any:
        return self._data[name]

    def __setitem__(self, name: str, value: Any) -> None:
        self._data[name] = value

    def __contains__(self, name: str) -> bool:
        return name in self._data


# ========= Unix Settings =========
class UnixSettings:
    """
    INI/Unix-style configuration manager with automatic file creation support.

    This class uses Python's `ConfigParser` to manage `.cfg` or `.ini`-style
    configuration files. It preserves sections and keys as written, and ensures
    compatibility with Unix-style key-value pairs.

    Example:
        settings = UnixSettings("config.cfg")
        settings.save("username", "admin")
        settings.write()
    """

    __slots__ = ("filepath", "separator", "comment", "config", "_logger", "_had_section")

    def __init__(self, filepath: str | Path, separator: str = "", comment: str = "#") -> None:
        """
        Initialize the UnixSettings object.

        Args:
            filepath (str | Path): Path to the INI/CFG file.
            separator (str): Separator used between key and value.
            comment (str): Comment character (default: "#").
        """
        self.filepath = Path(filepath)
        self.separator = separator
        self.comment = comment
        self._logger = logging.getLogger(f"{__name__}.UnixSettings")
        self._had_section = False
        self._initialize_config()

    def _ensure_file_exists(self) -> None:
        """
        Ensure the INI/CFG file exists. If not, create an empty one.
        """
        if not self.filepath.exists():
            try:
                self.filepath.parent.mkdir(parents=True, exist_ok=True)
                self.filepath.write_text("", encoding="utf-8")
                self._logger.info(f"Created new INI/CFG file: {self.filepath}")
            except Exception as e:
                self._logger.error(f"Failed to create INI/CFG file {self.filepath}: {e}")

    def _initialize_config(self) -> None:
        """
        Initialize the ConfigParser with Unix-friendly options.
        """
        self.config = ConfigParser(interpolation=None, strict=False, allow_no_value=True)
        self.config.optionxform = lambda optionstr: str(optionstr)  # preserve case
        self._load_file()

    def _load_file(self) -> None:
        """
        Load the INI/CFG file into memory.
        If no section headers exist, wrap the content inside `[DEFAULT]`.
        """
        self._ensure_file_exists()
        try:
            content = self.filepath.read_text(encoding="utf-8")
            # Detect whether file already contains at least one section
            self._had_section = any(
                line.strip().startswith("[") and line.strip().endswith("]")
                for line in content.splitlines() if line.strip()
            )
            # If no section headers are present, prepend `[DEFAULT]`
            if not self._had_section and content.strip():
                content = "[DEFAULT]\n" + content
            with StringIO(content) as buffer:
                self.config.read_file(buffer)
        except Exception as e:
            self._logger.error(f"Failed to load INI/CFG {self.filepath}: {e}")

    def ensure_section(self, section: str) -> None:
        """
        Ensure a section exists in the configuration file.
        """
        if not self.config.has_section(section) and section != "DEFAULT":
            self.config.add_section(section)

    def set(self, section: str, name: str, value: Union[str, int, float, bool]) -> None:
        """
        Set a key-value pair inside a specific section.
        """
        self.ensure_section(section)
        self.config.set(section, name, str(value))

    def has_section(self, section: str) -> bool:
        """Check if a section exists."""
        return self.config.has_section(section)

    def has_option(self, section: str, option: str) -> bool:
        """Check if a specific option exists inside a section."""
        return self.config.has_option(section, option)

    def load(self, default: Optional[dict[str, Any]] = None) -> dict[str, Any]:
        """
        Load the `[DEFAULT]` section into a dictionary.

        Args:
            default (dict | None): Fallback dictionary if loading fails.

        Returns:
            dict: Dictionary of key-value pairs.
        """
        if self.config.has_section("DEFAULT"):
            return dict(self.config.items("DEFAULT"))
        return default or {}

    def write(self) -> bool:
        """
        Write the in-memory configuration to disk.

        Returns:
            bool: True if successful, False otherwise.
        """
        try:
            with self.filepath.open("w", encoding="utf-8") as f:
                self.config.write(f, space_around_delimiters=bool(self.separator))
            return True
        except Exception as e:
            self._logger.error(f"Failed to write INI/CFG {self.filepath}: {e}")
            return False

    def save_file(self) -> bool:
        """
        Alias for `write()`, useful for backward compatibility with other code.
        """
        return self.write()

    def save(self, name: str, value: Union[str, int, float, bool]) -> None:
        """
        Save a key-value pair in the `[DEFAULT]` section.
        """
        self.config.set("DEFAULT", name, str(value))

    def remove(self, name: str) -> bool:
        """
        Remove a key from the `[DEFAULT]` section.

        Returns:
            bool: True if the key was removed, False otherwise.
        """
        return self.config.remove_option("DEFAULT", name)

    def exists(self, name: str) -> bool:
        """
        Check if a key exists in the `[DEFAULT]` section.
        """
        return self.config.has_option("DEFAULT", name)

    def get(self, name: str, default: Optional[Any] = None) -> Optional[Any]:
        """
        Retrieve a value from the `[DEFAULT]` section.

        Args:
            name (str): Key name.
            default (Any | None): Value to return if key is missing.

        Returns:
            Any: The stored value or the default.
        """
        return self.config.get("DEFAULT", name, fallback=default)

    def loadAll(self, name: str, includeName: bool = False) -> Dict[str, str]:
        """
        Load all keys in the `[DEFAULT]` section that start with a given prefix.

        Args:
            name (str): Prefix to filter keys.
            includeName (bool): If True, return the full key name,
                                otherwise return only the suffix.

        Returns:
            dict: Dictionary of matching key-value pairs.
        """
        result = {}
        for key, value in self.config.items("DEFAULT"):
            if key.startswith(name + "."):
                suffix = key if includeName else key[len(name) + 1 :]
                result[suffix] = value
        return result

    # Dictionary-like access
    def __getitem__(self, name: str) -> str:
        val = self.get(name)
        if val is None:
            raise KeyError(name)
        return val

    def __setitem__(self, name: str, value: Any) -> None:
        self.save(name, value)

    def __contains__(self, name: str) -> bool:
        return self.exists(name)
