cmake_minimum_required(VERSION 3.16)

project(VoiceAssistant VERSION 2.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6 components
find_package(Qt6 6.2 REQUIRED COMPONENTS
    Core
    Quick
    Qml
    Gui
    Multimedia
    Network
    WebSockets
    DBus
    Test
    Charts
    Positioning
)

# Application sources
set(APP_SOURCES
    src/main.cpp
    src/networkmanager.cpp
    src/networkmanager.h
    src/audioengine.cpp
    src/audioengine.h
    src/transcriptionmodel.cpp
    src/transcriptionmodel.h
    src/settingsmanager.cpp
    src/settingsmanager.h
    src/ttsengine.cpp
    src/ttsengine.h
)

# QML resources
qt6_add_resources(QML_RESOURCES
    qml.qrc
)

# Create executable
add_executable(${PROJECT_NAME}
    ${APP_SOURCES}
    ${QML_RESOURCES}
)

# Link Qt6 libraries
target_link_libraries(${PROJECT_NAME}
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::Multimedia
    Qt6::Network
    Qt6::WebSockets
    Qt6::DBus
)

# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Installation
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION /usr/bin
)

# Install desktop file
install(FILES voice-assistant.desktop
    DESTINATION /usr/share/applications
)

# Install icon
install(FILES resources/voice-assistant.png
    DESTINATION /usr/share/icons/hicolor/256x256/apps
)

# Enable testing
option(BUILD_TESTING "Build tests" ON)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
