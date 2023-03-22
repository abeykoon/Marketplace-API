const DEFAULT_CONFIG_ICON_PATH = "";

# Represents Configuration resource in Choreo marketplace
#
# + iconPath - Path to the icon for Config
public type Config record {|
    *CommonAttributes;
    string iconPath = DEFAULT_CONFIG_ICON_PATH;
|};
