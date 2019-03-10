#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int handle_header(FILE *map);
void handle_readout(int width, FILE *map, FILE *out);
int get_int(FILE *file);

int main(int argc, char **argv) {
    FILE *map;
    FILE *out;
    int width;

    if (argc == 1) {
        printf("usage: snesconv [path to tiled file].tmx\n");
        return 0;
    }
    map = fopen(argv[1], "r");
    out = fopen("./out.asm", "w");
    width = handle_header(map);
    printf("width: %d\n", width);
    handle_readout(width, map, out);

    fclose(map);
    fclose(out);

}

//returns the width of the map in tiles
int handle_header(FILE *map) {
    char tmp[512]; //larger than header (future proof)
    char widthChrs[5]; //largest map size is 2048 tiles, don't need more than 4
    char *widthString;
    int i, width;

    fgets(tmp, 512, map); //line 1
    fgets(tmp, 512, map); //line 2
    printf("%s\n", tmp);

    widthString = strstr(tmp, "width");
    if (widthString != NULL) {
        for (i = 7; i < 11; i++) {
            if (widthString[i] == '"') { break; }
            else { widthChrs[i - 7] = widthString[i]; }
        }
        widthChrs[i - 7] = '\0'; //null terminate
        width = (int)strtol(widthChrs, NULL, 10);
        return width;
    }
    else {
        printf("Error reading map, try downgrading to an earlier version of Tiled\n");
        return -1;
    }
}

void handle_readout(int width, FILE *map, FILE *out) {
    char tmp[512];
    int i;

    fgets(tmp, 512, map); //line 3
    fgets(tmp, 512, map); //line 4
    fgets(tmp, 512, map); //line 5

    for (i = 0; i < 32; i++) {
        printf("%d ", get_int(map));
    }


}

int get_int(FILE *file) {
    char cursor;
    char num[11];
    int i;

    for (i = 0; i < 11; i++) {
        cursor = getc(file);
        if (cursor == ',' || cursor == '\r' || cursor == '\n') {
            num[i] = '\0';
            break;
        }
        else { num[i] = cursor; }
    }
    return (int)strtol(num, NULL, 10);
}
