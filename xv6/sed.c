// Theodore Kim
// sed implementation (HW 1, Q 2 - 4 + Extra Credit)
// CS-UY 3224

#include "types.h"
#include "user.h"

char buf[512];

int
replace(int size, char *haystack, int needleSize, char *needle, char *replacement) {
	int i, j = 0, flag = 0;
	int start = 0, len;
	int output = 0;

	char temp;

	for (i = 0; i < size; ++i) {
		++len;
		if (haystack[i] == needle[j]) {
			++j;
			if (j == needleSize) {
				++output;
				flag = 1;
				while (j > 0) {
					haystack[i - (needleSize - j)] = replacement[j - 1];
					--j;
				}
				j = 0;
			}
		}
		else if (haystack[i] == '\n') {
			if (flag == 1) {
				temp = haystack[i];
				haystack[i] = '\0';
				printf(1, "%s", haystack + start);
				flag = 0;
				haystack[i] = temp;
			}
			start = i;
			len = 0;
		}
		else {
			j = 0;
		}
	}
	return output;
}

void
sed(int fd, char *from, char *to) {
	int n, total = 0;
	while((n = read(fd, buf, sizeof(buf))) > 0) {
		total += replace(n, buf, 3, from, to);
	}
	if(n < 0) {
		printf(1, "sed: read error\n");
		close(fd);
		exit();
	}
	else {
		printf(1, "\n\nFound and Replaced %d occurences\n", total);
	}
}

int
main(int argc, char *argv[]) {
	// buf = malloc(512 * sizeof(*char));

	int i, fd, fromSet = 0;
	char *filename, *from, *to;

	if(argc <= 1){
   		sed(0, "the", "xyz");
	    exit();
	}

	else if (argc == 2) {
		if ((fd = open(argv[1], 0)) < 0) {
			printf(1, "sed: cannot open %s\n", argv[1]);
      		close(fd);
      		exit();
		}
		sed(fd, "the", "xyz");
		close(fd);
	}

	else if (argc == 4) {
		for (i = 1; i < argc; ++i) {
			if (argv[i][0] == '-') {
				if (fromSet == 0) {
					from = argv[i] + 1;
					fromSet = 1;
				}
				else {
					to = argv[i] + 1;
				}
			}
			else {
				filename = argv[i];
			}
		}

		if ((fd = open(filename, 0)) < 0) {
			printf(1, "sed: cannot open %s\n", filename);
      		close(fd);
      		exit();
		}
		sed(fd, from, to);
		close(fd);
	}

	else {
		printf(1, "Sed accepts either 0, 1 or 3 arguments.\n");
	}

	exit();
}