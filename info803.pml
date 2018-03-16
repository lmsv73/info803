#define vert 1
#define rouge 0
#define bloque 0
#define debloque 1
#define entre 1
#define sortie 0

int timeGreen =  5000;
int timeRed   = 10000;
int timeOpen  = 30000;

int personne1 = 1;
int personne2 = 2;
int personne3 = 3;

int NB_ALLOWED = 2;
int allowed[NB_ALLOWED];


int indiceJournal = 0;

typedef Page {
    int id;
    bit entree;
}

Page pages[100];

// Activation de la porte si le voyant est allumé vert
chan activePorte = [100] of {bit};

// Envoie du code pour vérifier sa validité
chan passeBadge = [100] of {int};

// Activation du voyant
chan activeVoyant = [100] of {bit};

// Envoi de l'id de l'utilkisateur depuis le lecteur au voyant
chan sendIdToVoyant = [100] of {int};

init{
    allowed[0] = personne1;
    allowed[1] = personne2;

    run simulator();
    run lecteur();
    run voyant();
    run porte();
}

inline wait(x) {
    int a = 0;

    do
        :: a != x -> a = a + 1;
        :: a == x -> break;
    od;
}

inline pushJournal(id, entree) {
    pages[indiceJournal].id = id;
    pages[indiceJournal].entree = entree;
    
    indiceJournal++;
}

inline showJournal() {
    int i;

    printf("-----------JOURNAL-----------------\n");
    for(i:0..(indiceJournal - 1)) {
        printf("Utilisateur %d est entré\n", pages[i].id);
    }
}

proctype simulator() {
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
        :: accept -> printf("Badge valide\n"); activeVoyant!vert; sendIdToVoyant!id;
        :: !accept -> printf("Badge invalide\n"); activeVoyant!rouge; 
    fi
}

proctype voyant() {
    bool state;
    int id;
    activeVoyant?state;
    sendIdToVoyant?id;

    if
        :: state ->  activePorte!debloque; printf("Voyant vert pendant %d sec\n", timeGreen/1000); pushJournal(id, entre); wait(timeGreen*100); printf("Voyant éteint\n");
        :: !state -> activePorte!bloque; printf("Voyant rouge pendant %d sec\n", timeRed/1000); wait(timeRed*100);  printf("Voyant éteint\n");
    fi
}

proctype porte() {
    bool state;
    activePorte?state;

    if
        :: state -> printf("Porte ouverte pendant %d sec\n", timeOpen/1000); wait(timeOpen*100); printf("Porte fermée\n");
        :: else;
    fi

    showJournal();
}

