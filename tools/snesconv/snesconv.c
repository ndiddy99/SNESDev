#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    FILE *map;
    FILE *out;
    int i;

    if (argc == 1) {
        printf("usage: snesconv [path to tiled file].tmx\n");
        return 0;
    }
    map = fopen(argv[1], "r");
    out = fopen("./out.asm", "w");
    for (i = 0; i < 20; i++) {
        putc(getc(map), out);
    }

    fclose(map);
    fclose(out);

}
