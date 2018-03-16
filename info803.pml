#define vert 1
#define rouge 0
#define bloque 0
#define debloque 1

int timeGreen =  5000;
int timeRed   = 10000;
int timeOpen  = 30000;

int personne1 = 1;
int personne2 = 2;
int personne3 = 3;

int NB_ALLOWED = 2;
int allowed[NB_ALLOWED];

// Activation de la porte si le voyant est allumé vert
chan activePorte = [100] of {bit};

// Envoie du code pour vérifier sa validité
chan passeBadge = [100] of {int};

// Activation du voyant
chan activeVoyant = [100] of {bit};

// Démarrage du délai permettant de gérer les temps du voyant / porte
chan activeDelayPorte  = [100] of {int};
chan activeVoyantVert  = [100] of {int};
chan activeVoyantRouge = [100] of {int};

init{
    allowed[0] = personne1;
    allowed[1] = personne2;

    run personne();
    run lecteur();
    run voyant();
    run porte();
    run activeDelayPorte();
    run activeVoyantVert();
    run activeVoyantRouge();
}

inline wait(x) {
    int a = 0;

    do
        :: a != x -> a = a + 1;
        :: a == x -> break;
    od;
}

proctype personne() {
    passeBadge!personne1;
}

proctype lecteur() {
    int id, i;
    bool accept = false;
    
    passeBadge?id;

    printf("Lecture du badge %d\n", id);

    for (i: 0..(NB_ALLOWED - 1)) {
        if
            :: id == allowed[i] -> accept = true;
            :: else;
        fi
    }
    
    if
        :: accept -> printf("Badge valide\n"); activeVoyant!vert; activeVoyantVert!timeGreen;
        :: !accept -> printf("Badge invalide\n"); activeVoyant!rouge; activeVoyantRouge!timeRed;
    fi
}

proctype voyant() {
    bool state;
    activeVoyant?state;

    if
        :: state -> activePorte!debloque; 
        :: !state -> activePorte!bloque;
    fi
}

proctype porte() {
    bool state;
    activePorte?state;

    if
        :: state -> activeDelayPorte!timeOpen;
        :: else;
    fi
}

proctype delayPorte() {
    int delay;
    activeDelayPorte?delay;
    printf("Porte ouverte pendant %d sec\n", timeOpen/1000);
    wait(delay);
}

proctype delayVoyantVert() {
    int delay;
    activeVoyantVert?delay;
    printf("Voyant vert pendant %d sec\n", timeGreen/1000);
    wait(delay);
}

proctype delayVoyantRouge() {
    int delay;
    activeVoyantRouge?delay;
    printf("Voyant rouge pendant %d sec\n", timeRed/1000);
    wait(delay);
}
