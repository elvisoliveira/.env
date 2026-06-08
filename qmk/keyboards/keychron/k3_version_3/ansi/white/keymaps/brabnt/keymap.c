/* Keychron K3 Version 3 (ANSI white / LED-matrix) — ABNT2 helper keymap.
 * Based on the stock *white* default (lighting uses BL_* keycodes, not UG_*).
 *
 * The OS must be on the br/abnt2 layout. Under abnt2 the stock keys already
 * produce all Portuguese (ç, dead keys ´`~^, accents). The characters an ANSI
 * board physically lacks (/ ? \ |) are placed on the base layer:
 *   / ?  => BR_SLSH (KC_INT1), on the key right of Space (old Fn slot).
 *   \ |  => BR_BSLS (KC_NUBS), on the \ key.
 * Displaced by these: the Fn key moves to the Right Ctrl position, and the
 * abnt2 ] } (KC_BSLS) moves to Fn + \. Insert is the last key of the top row;
 * Fn + that key steps the backlight (BL_STEP). Backlight on/off = Fn + Tab.
 */
#include QMK_KEYBOARD_H
#include "keychron_common.h"

#define BR_SLSH KC_INT1   // under abnt2 => / ?
#define BR_BSLS KC_NUBS   // under abnt2 => \ |

enum layers {
    MAC_BASE,
    MAC_FN,
    WIN_BASE,
    WIN_FN,
};
// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [MAC_BASE] = LAYOUT_ansi_84(
        KC_ESC,   KC_BRID,  KC_BRIU,  KC_MCTRL, KC_LNPAD, BL_DOWN,  BL_UP,    KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,  KC_VOLU,  KC_SNAP,  KC_DEL,   KC_INS,
        KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,     KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,  KC_EQL,   KC_BSPC,            KC_PGUP,
        KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,     KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,  KC_RBRC,  BR_BSLS,            KC_PGDN,
        KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,     KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,            KC_ENT,             KC_HOME,
        KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,     KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,            KC_RSFT,  KC_UP,    KC_END,
        KC_LCTL,  KC_LCMMD, KC_LOPTN,                               KC_SPC,                                 KC_RCMMD,BR_SLSH,  MO(MAC_FN),KC_LEFT,  KC_DOWN,  KC_RGHT),

    [MAC_FN] = LAYOUT_ansi_84(
        _______,  KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,    KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,   KC_F12,   _______,  _______,  BL_STEP,
        _______,  BT_HST1,  BT_HST2,  BT_HST3,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        BL_TOGG,  BL_STEP,  BL_UP,    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_BSLS,            _______,
        _______,  _______,  BL_DOWN,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,            _______,
        _______,            _______,  _______,  _______,  _______,  BAT_LVL,  _______,  _______,  _______,  _______,  _______,            _______,  _______,  _______,
        _______,  _______,  _______,                                _______,                                _______,  _______,  _______,  _______,  _______,  _______),

    [WIN_BASE] = LAYOUT_ansi_84(
        KC_ESC,   KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,    KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,   KC_F12,   KC_PSCR,  KC_DEL,   KC_INS,
        KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,     KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,  KC_EQL,   KC_BSPC,            KC_PGUP,
        KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,     KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,  KC_RBRC,  BR_BSLS,            KC_PGDN,
        KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,     KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,            KC_ENT,             KC_HOME,
        KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,     KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,            KC_RSFT,  KC_UP,    KC_END,
        KC_LCTL,  KC_LGUI,  KC_LALT,                                KC_SPC,                                 KC_RALT, BR_SLSH,  MO(WIN_FN),KC_LEFT,  KC_DOWN,  KC_RGHT),

    [WIN_FN] = LAYOUT_ansi_84(
        _______,  KC_BRID,  KC_BRIU,  KC_TASK,  KC_FILE,  BL_DOWN,  BL_UP,    KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,  KC_VOLU,  _______,  _______,  BL_STEP,
        _______,  BT_HST1,  BT_HST2,  BT_HST3,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        BL_TOGG,  BL_STEP,  BL_UP,    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_BSLS,            _______,
        _______,  _______,  BL_DOWN,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,            _______,
        _______,            _______,  _______,  _______,  _______,  BAT_LVL,  _______,  _______,  _______,  _______,  _______,            _______,  _______,  _______,
        _______,  _______,  _______,                                _______,                                _______,  _______,  _______,  _______,  _______,  _______)
};
// clang-format on

/* Held-modifier shortcuts, all reachable from the easy keys:
 *
 *   Ctrl + Up/Down    => Page Up / Page Down
 *   Shift + Backspace => Delete (forward delete, without reaching the top row)
 *
 * In both cases the held modifier must NOT reach the host or it would change
 * meaning — Ctrl+PgUp is "previous tab" in many apps, and Shift+Del is a cut /
 * permanent-delete. So del_mods() clears it before register_code(), then
 * set_mods() restores it in the internal state right after, WITHOUT re-sending
 * the report. A second press still sees the modifier and other combos keep
 * working.
 *
 * Holding the key keeps the substitute registered, so the OS auto-repeats.
 * MOD_MASK_CTRL / MOD_MASK_SHIFT match both left and right, on every layer.
 */
static bool ctrl_pgup_held  = false;
static bool ctrl_pgdn_held  = false;
static bool shift_fdel_held = false;   // Shift+Backspace -> Delete

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (!process_record_keychron_common(keycode, record)) {
        return false;
    }
    switch (keycode) {
        case KC_UP:
            if (record->event.pressed) {
                if (get_mods() & MOD_MASK_CTRL) {
                    uint8_t mods = get_mods();
                    ctrl_pgup_held = true;
                    del_mods(MOD_MASK_CTRL);   // send clean PgUp...
                    register_code(KC_PGUP);
                    set_mods(mods);            // ...then restore Ctrl (not re-sent)
                    return false;
                }
            } else if (ctrl_pgup_held) {
                ctrl_pgup_held = false;
                unregister_code(KC_PGUP);
                return false;
            }
            return true;
        case KC_DOWN:
            if (record->event.pressed) {
                if (get_mods() & MOD_MASK_CTRL) {
                    uint8_t mods = get_mods();
                    ctrl_pgdn_held = true;
                    del_mods(MOD_MASK_CTRL);
                    register_code(KC_PGDN);
                    set_mods(mods);
                    return false;
                }
            } else if (ctrl_pgdn_held) {
                ctrl_pgdn_held = false;
                unregister_code(KC_PGDN);
                return false;
            }
            return true;
        case KC_BSPC:
            if (record->event.pressed) {
                if (get_mods() & MOD_MASK_SHIFT) {
                    uint8_t mods = get_mods();
                    shift_fdel_held = true;
                    del_mods(MOD_MASK_SHIFT);  // clean Del, not Shift+Del (=paste)
                    register_code(KC_DEL);
                    set_mods(mods);            // ...then restore Shift (not re-sent)
                    return false;
                }
            } else if (shift_fdel_held) {
                shift_fdel_held = false;
                unregister_code(KC_DEL);
                return false;
            }
            return true;
    }
    return true;
}
