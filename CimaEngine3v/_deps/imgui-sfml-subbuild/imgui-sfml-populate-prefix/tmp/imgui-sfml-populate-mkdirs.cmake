# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-src")
  file(MAKE_DIRECTORY "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-src")
endif()
file(MAKE_DIRECTORY
  "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-build"
  "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix"
  "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix/tmp"
  "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix/src/imgui-sfml-populate-stamp"
  "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix/src"
  "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix/src/imgui-sfml-populate-stamp"
)

set(configSubDirs Debug)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix/src/imgui-sfml-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/ariel/Library/CloudStorage/OneDrive-Personal/Documentos/02 ESCOLARES/03 UNIVERSIDAD/UABC/07 Semestre/Videojuegos/Repositorio/CimaEngine3v/_deps/imgui-sfml-subbuild/imgui-sfml-populate-prefix/src/imgui-sfml-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
