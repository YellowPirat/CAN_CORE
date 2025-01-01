// To get this working:
// The overlay support must be enabled in the bootloader config which can be done like so:
// ./scripts/config --file .config --enable OF_LIBFDT_OVERLAY 
// Create a file cmd/process_overlays.c and add the following code to it
// Add the following line to the file cmd/Makefile
// obj-y += process_overlays.o
// Run make to compile the bootloader
#include <common.h>
#include <command.h>
#include <linux/string.h>

static int do_process_overlays(struct cmd_tbl *cmdtp, int flag, int argc,
                            char *const argv[])
{
    if (argc != 3) {
        printf("Usage: process_overlays <config_addr> <overlay_addr>\n");
        return CMD_RET_USAGE;
    }

    char *curr = (char *)simple_strtoul(argv[1], NULL, 16);
    ulong overlay_addr = simple_strtoul(argv[2], NULL, 16);
    char cmd_buf[128];
    
line_start:
    while (*curr) {
        // Skip whitespace at start of line
        while (*curr == ' ' || *curr == '\t')
            curr++;
            
        if (strncmp(curr, "dtoverlay=", 10) == 0) {
            curr += 10;  // Skip "dtoverlay="
            char *name_end = strchr(curr, '\n');
            if (!name_end) {
                name_end = curr;
                while (*name_end && *name_end != '\r' && *name_end != ' ')
                    name_end++;
            }
            
            char saved = *name_end;
            *name_end = '\0';
            
            sprintf(cmd_buf, "fatload mmc 0:1 0x%lx overlays/%s.dtbo", overlay_addr, curr);
            if (run_command(cmd_buf, 0) >= 0) {
                sprintf(cmd_buf, "fdt apply 0x%lx", overlay_addr);
                if (run_command(cmd_buf, 0) >= 0) {
                    printf("Successfully applied overlay: %s\n", curr);
                }
            }
            
            *name_end = saved;
            curr = name_end + 1;
        } else {
            // Skip to next line if not dtoverlay
            while (*curr && *curr != '\n')
                curr++;
            if (*curr == '\n')
                curr++;
            goto line_start;  // Start processing next line
        }
    }

    return 0;
}

U_BOOT_CMD(
    process_overlays, 3, 1, do_process_overlays,
    "Process and apply device tree overlays from config",
    "<config_addr> <overlay_addr>\n"
    "    - Process config at <config_addr> and load overlays to <overlay_addr>"
);