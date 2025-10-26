cmake_minimum_required(VERSION 3.16)

enable_testing()

find_package(Qt6 REQUIRED COMPONENTS Test)

# Test executable for AudioEngine
add_executable(test_audioengine
    test_audioengine.cpp
    ../src/audioengine.cpp
)

target_link_libraries(test_audioengine
    Qt6::Test
    Qt6::Core
)

add_test(NAME test_audioengine COMMAND test_audioengine)

# Test executable for TranscriptionModel
add_executable(test_transcriptionmodel
    test_transcriptionmodel.cpp
    ../src/transcriptionmodel.cpp
)

target_link_libraries(test_transcriptionmodel
    Qt6::Test
    Qt6::Core
)

add_test(NAME test_transcriptionmodel COMMAND test_transcriptionmodel)

# Test executable for SettingsManager
add_executable(test_settingsmanager
    test_settingsmanager.cpp
    ../src/settingsmanager.cpp
)

target_link_libraries(test_settingsmanager
    Qt6::Test
    Qt6::Core
)

add_test(NAME test_settingsmanager COMMAND test_settingsmanager)
