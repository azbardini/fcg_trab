#include <cstdio>
#include <GLFW/glfw3.h>  // Criação de janelas do sistema operacional
#include "animals.hpp"

#define CUBE_SIZE 0.8
#define CUBE_SIZE_RABBIT 0.3
#define PLANE_SIZE_X 20
#define PLANE_SIZE_Z 20

using namespace glm;

Animal::Animal(int id, vec3 position, bool isRabbit = false){
    this->id = id;
    this->position = position;
    this->height = CUBE_SIZE;
    this->width = CUBE_SIZE;
    this->depth = CUBE_SIZE;
    this->hitBoxMax = vec3(0.0f, 0.0f, 0.0f);
    this->hitBoxMin = vec3(0.0f, 0.0f, 0.0f);
    this->isRabbit = isRabbit;
    this->isAlive = true;

    if(isRabbit){
        this->height = CUBE_SIZE_RABBIT;
        this->width = CUBE_SIZE_RABBIT;
        this->depth = CUBE_SIZE_RABBIT;
    }
}

Animal::Animal(){
    this->height = CUBE_SIZE;
    this->width = CUBE_SIZE;
    this->depth = CUBE_SIZE;
    this->isAlive = true;
}

void Animal::setPosition(vec3 position){
    this->position = position;
}

void Animal::updateHitBox(){
    hitBoxMin.x = position.x - width;
    hitBoxMin.y = position.y - height;
    hitBoxMin.z = position.z - depth;
    hitBoxMax.x = position.x + width;
    hitBoxMax.y = position.y + height;
    hitBoxMax.z = position.z + depth;
}

bool Animal::wallColision(){
    if(hitBoxMin.x< -PLANE_SIZE_X+1 || hitBoxMin.x > PLANE_SIZE_Z -1)
        return true;
    if(hitBoxMin.z<-PLANE_SIZE_X +1 || hitBoxMin.z>PLANE_SIZE_Z-1)
        return true;
    if(hitBoxMax.x< -PLANE_SIZE_X+1 || hitBoxMax.x > PLANE_SIZE_Z -1)
        return true;
    if(hitBoxMax.z<-PLANE_SIZE_X +1 || hitBoxMax.z>PLANE_SIZE_Z-1)
        return true;
    return false;
}

bool Animal::pointInsideCube(vec3 point){
    if(point.x>= hitBoxMin.x && point.x <=hitBoxMax.x)
        if(point.y>=hitBoxMin.y && point.y <=hitBoxMax.y)
            if(point.z>=hitBoxMin.z && point.z<=hitBoxMax.z)
                return true;
    return false;
}

bool Animal::cubeInsideCube(vec3 otherHitBoxMin, vec3 otherHitBoxMax){
    vec3 aux;
    if(pointInsideCube(otherHitBoxMin))
        return true;
    if(pointInsideCube(otherHitBoxMax))
        return true;

    aux = vec3(otherHitBoxMin.x, otherHitBoxMin.y, otherHitBoxMax.z);
    if(pointInsideCube(aux))
        return true;

    aux = vec3(otherHitBoxMin.x, otherHitBoxMax.y, otherHitBoxMax.z);
    if(pointInsideCube(aux))
        return true;

    aux = vec3(otherHitBoxMin.x, otherHitBoxMax.y, otherHitBoxMin.z);
    if(pointInsideCube(aux))
        return true;

    aux = vec3(otherHitBoxMax.x, otherHitBoxMax.y, otherHitBoxMin.z);
    if(pointInsideCube(aux))
        return true;

    aux = vec3(otherHitBoxMax.x, otherHitBoxMin.y, otherHitBoxMin.z);
    if(pointInsideCube(aux))
        return true;

    aux = vec3(otherHitBoxMax.x, otherHitBoxMin.y, otherHitBoxMax.z);
    if(pointInsideCube(aux))
        return true;

    return false;
}
