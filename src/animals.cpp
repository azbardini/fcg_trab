#include <cstdio>
#include <GLFW/glfw3.h>  // Criação de janelas do sistema operacional
#include "animals.hpp"

#define CUBE_SIZE 0.5

using namespace glm;

Animal::Animal(int id, vec3 position){
    this->id = id;
    this->position = position;
    this->height = CUBE_SIZE;
    this->width = CUBE_SIZE;
    this->depth = CUBE_SIZE;
}
