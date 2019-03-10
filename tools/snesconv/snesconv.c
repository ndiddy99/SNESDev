#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int handle_header(FILE *map);
void handle_readout(int width, FILE *map, FILE *out);
uint32_t get_tilenum(FILE *file);
void handle_write(uint32_t data, FILE *file);

int main(int argc, char **argv) {
    FILE *map;
    FILE *out;
    int width;

    if (argc == 1) {
        printf("usage: snesconv [path to tiled file].tmx\n");
        return 0;
    }
    map = fopen(argv[1], "r");
    out = fopen("./out.bin", "w");
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
    int i, j, k, n;
    uint32_t curr;

    fgets(tmp, 512, map); //line 3
    fgets(tmp, 512, map); //line 4
    fgets(tmp, 512, map); //line 5

    for (i = 0; i < width / 32; i++) {
        for (j = 0; j < 14; j++) {
            for (k = 0; k < i * 32; k++) {
                get_tilenum(map); //advance file pointer
            }
            for (n = 0; n < 32; n++) {
                curr = get_tilenum(map);
//                printf("%d ", curr);
                handle_write(curr, out);
            }
            fgets(tmp, 512, map);
//            printf("\n");
        }
//        printf("\n\n");
        rewind(map);
        fgets(tmp, 512, map); //line 1
        fgets(tmp, 512, map); //line 2
        fgets(tmp, 512, map); //line 3
        fgets(tmp, 512, map); //line 4
        fgets(tmp, 512, map); //line 5
    }
}

uint32_t get_tilenum(FILE *file) {
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
    return strtoul(num, NULL, 10);
}

#define HORIZ_FLIP 16384
#define VERT_FLIP 32768

void handle_write(uint32_t data, FILE *file) {
    uint32_t tileNum = data - 1; //tiled indexes data by 1
    uint32_t out;
    uint8_t c1, c2;

    out = ((tileNum & 496) << 2) + ((tileNum & 15) << 1); //496 = %111110000
    if (tileNum & 2147483648) { //if horizontally flipped
        out |= HORIZ_FLIP;
    }
    if (tileNum & 1073741824) { //if vertically flipped
        out |= VERT_FLIP;
    }
    if (out) { printf("tilenum : %u, out : %u\n", tileNum, out); }

    c1 = (uint8_t)(out & 255); //low byte
    c2 = (uint8_t)((out >> 8) & 255); //high byte
    putc(c1, file);
    putc(c2, file);

}
