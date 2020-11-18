#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define COW     0
#define BUNNY   1
#define PLANE   2
#define WALL1   3
#define MOON    4
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0; //COW
uniform sampler2D TextureImage1; //BUNNY
uniform sampler2D TextureImage2; //PLANE
uniform sampler2D TextureImage3; //WALL
uniform sampler2D TextureImage4; //MOON

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923


vec4 P;
vec4 C;
void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(vec4(0.0,1.0,0.0,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l + 2*n*dot(n,l);

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd = vec3(0.0,0.0,0.0); // Refletância difusa
    vec3 Ks = vec3(0.0,0.0,0.0); // Refletância especular
    vec3 Ka = vec3(0.0,0.0,0.0); // Refletância ambiente
    float q = 1; // Expoente especular para o modelo de iluminação de Phong

    if ( object_id == COW )
    {
        // Propriedades espectrais da vaca
        Kd = vec3(0.4, 0.4, 0.4);
        Ka = vec3(0.2, 0.2, 0.2);
        q = 1.0;

        // Projeção planar
        float minx = bbox_min.x;
        float maxx = bbox_max.x;
        float miny = bbox_min.y;
        float maxy = bbox_max.y;
        float minz = bbox_min.z;
        float maxz = bbox_max.z;
        P = position_model;
        U = (P.x-minx)/(maxx-minx);
        V = (P.y-miny)/(maxy-miny);
    }
    else if ( object_id == BUNNY )
    {
        // Propriedades espectrais do coelho
        // Kd = vec3(0.08, 0.4, 0.8);
        // Ks = vec3(0.8, 0.8, 0.8);
        // Ka = vec3(0.04, 0.2, 0.4);
        q = 4.0;

        //Projeção esférica
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
        float rho = 1.0;
        P = position_model;
        C = bbox_center;
        vec4 pLine = C + (rho * ((P-C)/length(P-C)));
        vec4 pVect = pLine - C;
        float phi = asin(pVect.y/rho);
        float theta = atan(pVect.x, pVect.z);
        V = (phi + M_PI_2) / M_PI;
        U = (theta + M_PI) / (2 * M_PI);
    }
    else if ( object_id == PLANE )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x*8;
        V = texcoords.y*8;

       // Propriedades espectrais do plano
        Kd = vec3(0.2, 0.2, 0.2);
        Ks = vec3(0.3, 0.3, 0.3);
        Ka = vec3(0.2,0.2,0.2); // Refletância ambiente
        q = 10.0;
    }
    else if ( object_id == WALL1)
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x*16;
        V = texcoords.y;

       // Propriedades espectrais do plano
        Kd = vec3(0.2, 0.2, 0.2);
        Ks = vec3(0.3, 0.3, 0.3);
        Ka = vec3(0.2,0.2,0.2); // Refletância ambiente
        q = 10.0;
    }
    else if ( object_id == MOON)
    {
       // Propriedades espectrais do plano
        Kd = vec3(0.8, 0.8, 0.8);
        Ks = vec3(0.8, 0.8, 0.8);
        Ka = vec3(1.0,1.0,1.0); // Refletância ambiente
        q = 10.0;

          //Projeção esférica
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
        float rho = 1.0;
        P = position_model;
        C = bbox_center;
        vec4 pLine = C + (rho * ((P-C)/length(P-C)));
        vec4 pVect = pLine - C;
        float phi = asin(pVect.y/rho);
        float theta = atan(pVect.x, pVect.z);
        V = (phi + M_PI_2) / M_PI;
        U = (theta + M_PI) / (2 * M_PI);

    }

   // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
    vec3 GrassTexture = texture(TextureImage0, vec2(U,V)).rgb;
    vec3 FurTexture = texture(TextureImage1, vec2(U,V)).rgb;
    vec3 CowTexture = texture(TextureImage2, vec2(U,V)).rgb;
    vec3 FenceTexture = texture(TextureImage3, vec2(U,V)).rgb;
    vec3 MoonTexture = texture(TextureImage4, vec2(U,V)).rgb;
    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0); // o espectro da fonte de luz
    // Espectro da luz ambiente
    vec3 Ia = vec3(0.2, 0.2, 0.2); // o espectro da luz ambiente
    // Equação de Iluminação simples
    float simple_lambert = max(0,dot(n,l));
    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = Kd*I*max(0, dot(n,l)); // o termo difuso de Lambert
    // Termo ambiente
    vec3 ambient_term =  Ka*Ia;// o termo ambiente
    // Termo especular utilizando o modelo de iluminação de Phong
    vec3 phong_specular_term  = Ks*I*pow(max(0, dot(r,v)), q); // o termo especular de Phong

    if ( object_id == COW )
    {
    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
    color = CowTexture*(lambert_diffuse_term + ambient_term + phong_specular_term);
    }
    else if ( object_id == BUNNY )
    {
    color = FurTexture * (simple_lambert + 0.01);
    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
    // color = FurTexture*(lambert_diffuse_term + ambient_term + phong_specular_term);
    }
    else if ( object_id == PLANE )
    {
    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
    color = GrassTexture*(lambert_diffuse_term + ambient_term + phong_specular_term);
    }
    else if ( object_id == WALL1 )
    {
    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
    color = FenceTexture*(lambert_diffuse_term + ambient_term + phong_specular_term);
    }
    else if ( object_id == MOON )
    {
    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
    color = MoonTexture*(lambert_diffuse_term + ambient_term + phong_specular_term);
   }

        // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);

}

