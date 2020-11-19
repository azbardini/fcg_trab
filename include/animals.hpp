#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>
#include <glm/gtc/type_ptr.hpp>

#ifndef _animals_hpp
#define _animals_hpp

using namespace glm;

class Animal{
    int id;
    float width, height, depth;
    bool alive;
public:
    vec3 position, hitBoxMin, hitBoxMax;
    Animal(int id, vec3 position);
    void updateHitBox();
    bool wallColision();
    void setPosition(vec3 position);
    bool pointInsideCube(vec3 point);
    bool cubeInsideCube(vec3 otherHitBoxMin, vec3 otherHitBoxMax);
};

#endif // _animals_hpp
