#!/usr/bin/env bash
#
# rw-node-setup.sh — Selfsteal (VLESS REALITY) + XHTTP для ноды Remnawave
#
# Разворачивает серверную часть ноды одной командой:
#   nginx на хосте, сертификат Let's Encrypt, сайт-заглушка,
#   REALITY-фоллбэк через unix-сокет, XHTTP через grpc_pass,
#   проброс /dev/shm в контейнер ноды, sysctl, ufw.
#
# Config Profile и Hosts в панели создаются вручную — скрипт печатает
# готовый JSON и таблицу параметров в конце работы.
#
# Лицензия: MIT
#
set -Eeuo pipefail

VERSION="1.0.0"
SELF="$(basename "$0")"

# ---------------------------------------------------------------- вывод

if [[ -t 1 ]]; then
  C_R=$'\e[31m'; C_G=$'\e[32m'; C_Y=$'\e[33m'; C_B=$'\e[36m'; C_D=$'\e[2m'; C_0=$'\e[0m'; C_BOLD=$'\e[1m'
else
  C_R=''; C_G=''; C_Y=''; C_B=''; C_D=''; C_0=''; C_BOLD=''
fi

step()  { printf '\n%s==>%s %s%s%s\n' "$C_B" "$C_0" "$C_BOLD" "$*" "$C_0"; }
ok()    { printf '  %s+%s %s\n' "$C_G" "$C_0" "$*"; }
info()  { printf '  %s.%s %s\n' "$C_D" "$C_0" "$*"; }
warn()  { printf '  %s!%s %s\n' "$C_Y" "$C_0" "$*" >&2; }
err()   { printf '  %sx%s %s\n' "$C_R" "$C_0" "$*" >&2; }
die()   { err "$*"; exit 1; }

on_err() {
  local line=$1
  err "Ошибка на строке $line. Установка прервана."
  err "Ничего из уже сделанного не откатывается автоматически — см. раздел ОТКАТ в --help."
}
trap 'on_err $LINENO' ERR

# ---------------------------------------------------------------- заглушки
TEMPLATE_COUNT=4
template_name() {
  case "$1" in
    1) echo "Nordvale Analytics — SaaS-лендинг, тёмная тема" ;;
    2) echo "Hollis & Mercer — консалтинг, классическая вёрстка" ;;
    3) echo "Fieldnote — дизайн-студия, минимализм, авто-тема" ;;
    4) echo "Orbit Mail — статус-страница сервиса" ;;
    *) echo "неизвестный шаблон" ;;
  esac
}

template_data() {
  case "$1" in
    1) cat <<'RWTPL1'
H4sIAAAAAAAC/8VZy27kxhXd6yvKFAyM4mY3yX6oX2pAMx57BpmxBzNjG8mumqxuVkSy6GJ1t3oE
AYGRRdaBfyJA1snegbf5CH9Jzi2S/ZQ0crzIRmzW495z3/dS408+//rZ+z+8ec5ikyaTkzE9WMKz
+YUjMocWBI/wSIXhLIy5LoS5cBZm5vadejnjqbhwllKscqWNw0KVGZHh2EpGJr6IxFKGwrUvDZlJ
I3niFiFPxIVPNIw0iZh8pXS0xBq7zHiyNjIs2C9//pF9nQvNjVRYZBJkk0TORRYKNlOaJWouCzo6
bpVE9gBFogi1zOnyDqY7+EwXMokKoihCDnrZnPEsYlotjHAVCKSysBiYUSqxB1kqIzfl+koYNtNC
zmPDlIWqdNEkqQqzJkBDrZS5cd3pfHjqRb7vn49cN+eZSIanfs+fBgHeE5mJ4WngB70gwqsR12Z4
KnoimrXxmgJGNDztTwedgcA7D0NIMjztdAbtWf/25Hc3U3XtFvIDgA+nEE9oFysjwJvLbOiNch5F
tOfdnkxVtL6Z8vBqDumyaLjk+gmBOxuFKlG6eicAZ6MZVDb0e/l1y2/2mMvzPBFusS6MSBtPAfnq
NQ/f2dcvcLLhvBNzJdg3L53GWzVVRjVeiGQpoGHeuNSweaPgWeEWQsvZyF2J6ZU0LvFwixQ6igkh
z8g5JC9EdHvSXGme36T8unSdoe/1vXwrFuMLo7aysaCTX9+ekLsKfbNRgzEqHfr5NStUIiNWykf6
PhvlqpBk1SG50NV6ZFQOZe0oR8+n/InfbvjnjaDdaPa7Z3Y30ip3ZzIxQg+nyUI/6efXZ6MPrswi
cQ2UtycZX95EssgTvh7OEnE9gkzzzJVQVTEk4wk9+tMCbGdrt3LMYZFzBMlUmJUQ2Si2LjXsWZma
8HP1UYJznoM5FGR1uqoIeN4oEQb7LjEgTblNzxepBckWyT5ZohFAnFGCuHKtCw8zlYmSJlxMDH0L
iS7zm12fsV56NiLXcSMRqjJq7e3q+DBWS5jmyNEgYGh4ZbL7bFWZ+Ry7hGBUGVjzSC6KYa8WewPx
2J8/kSmlJ7gYGMZCq5ua6ADXmcfOA+tA/s2WUpjwNH/Sxkaju1w1ugFZmhC5lYH8pn+Hftsi3bdC
1xvt+HEvjMmoIhJ3aXBHjsHG3V1yziCw7zWdbklHq9WxEa0Kdq626Z12XQqqIf3B1anJjpNBmV7q
hHA6m8022vfJOIF3p/rvMvyuLN0Dz+x6XomgOY9VYXZxGI1EkXMNGKMHveIuV0IB0EjqG5XMtYxG
9AcnUqwgpePaIs2KoRa54OYJ5RHEs2mkMoN2n/iUZhr+TJ+dlbokeQ+1VAJ4EN2+jmxoUgDMErUa
xjKKEOZVLqMwZ94G/LFNbMHYRkFADlvmu+oKm24EniYqvNrRfJsYH/tocOij3hYAw7nsI77Zrm1u
rYWSmA4XOSogKqg4ZNf0epRx4mAntEiGe2BVflsn785xTrs9KURIbraJ4a6N4Vrn5PJ3GoVyDUr4
b/COoLfvHe3gIEj71iwh1xGL2zsCUyU9EK1/l2Tl1fwj6u+WXNCQmZsD7r/aKz/qbtbTDJ8m4qYu
xd6nNSXgTHheIFlWP/a04R1lZlCKGya6sc5j69gwETOzn2S2YjxYw4nWvYraJppdBMGv8tsu+a2J
mtki3QWsiXJJFXwlaoqLE+hswiHUtEi4pvcCFlrUhjxtz6aDrnfbjNSqjq3TWb/rdwa3JzM0QNuu
5V7v3eio41lvf9hFKG72CsPDLcd+dSgzX4/MVYJ7fLmv7W+VZD3g9mTcqvrhcasaKKgTrcYLoSfj
SC4Zqm1RYGoAe2cyRs8wOWFsd4f6IIcWsVws56ycL5yg47CyHpe/aRJ5qq4vHI9RW8hoDf1acuEQ
PJDOuYlZdOG8bjO//2rA+kmH9Vjb7bAu679of6iPVy2205qMQ6lDDA0hqPr9ZhcDxfrC6dAPDab0
rK6UbTpdaQFiCbaeOUicFuSxci2SSpJETsacxVrMcJ1yEDmlM3lT/Rq3OGjh0B2nY7VyJi/UiknD
VkpfFQ8dzuGecB5QLn88dDZSYeFMPlfhHsVxqwSNc5VF0Lg59R2axjAyvkOAYFSje7A2WbGUubQ8
bH1ycmztA0NTe1YbOvYnX+xMZibmhhULvZRLUdixjocQXsKinGmBMRGOLEwT7PyKQr7xH7RcznbS
BDlRmIJhqhQpp1GwwShguAljOwHOFiJxbTqOuOEN8BYZncYMuFYLtoolDmJYBhB0K+z7hRQmWWMs
LQhpCmdbN2F8hinUBT0XJSVByA3ZSjDMHownKpsXMhJEmb1//c6S5QnEiNZMLzJIkVdC7GhHk9Xt
6q4p0EptTBGJFPp7qtQVlLLiyZWJkd/nsTXKHReZ7cGcfeu/BQoLLKrcoASyceDyx4HlqvbLOUZd
7iD6ppNOM/h03JpOxtRnTF6LCBnUKpsVfGk9025sWN1LyO9jEM+2pC6X8+bWhBjcEbEL82hy7Y73
2ZbY5yJXxrpYhmZDRI8mMxg0B90dAS/fvGR8yWXCpzKRZn1IaEeTVVvDJLLTNhVUgRBMviPnJx+Z
C0iFhSMY1N1snWN3A24MdHF78goOy3Kt0NRsAGF5nE/eoPiQO7MygzOKuiRcUFsUsYwSLLybz7nM
CjhvaBYUbTAbIkNRUFDMRBqBqVmsFrr8gpMpY70IFUJY7N8vFNEr5DWFiIlxb66sp++o9j7wb+mj
DNv9KFODf6aASgObocJJGGyq0KLIodTCAoNvudYrtJiTWLhOMU+GRgrJUJpLIZYCoU3pntg32dtF
ViBbMHRIIJuhFDMYSmXlRyOEWOB5mJZVzmCz7LGiXGYq5aTQRGhT1GK8jBJRYixyeSUAT81mKNka
TSp4RcJYze6nJ+giJZdHIkJqnCHHMI4zSFsSDCJJeY6R1Sik1czuFPFU0d1MUSmmr1dZ8VjoX+Mw
g1vXoJ9D3Wv7CYfURNb+5iWTRe310CRNPuzt83fvLXIO688zOMFKTGPKUrCc4GmTPUskOhOWyKlG
XyVK/b4BaZU12JfKXm5+9fz9IdCdWKpC6Die4k3apFD6gqoEQ+NHIcazUDSQyaGltgfdrIt7oov6
7W14UQ+y12ycBx46Cs+pOxPqk7e9id3RKhEXjkznDqPOEfE2FegbniH/Ehp2JRNFuQQ1AQNwtGFm
KzQc79oHK4et8ejgeR1cOOCKhaBcgCbVFThUnxPRiNxPYHBIYPArCfhHEPyPYdj0Xl7Dh7Ze9fD0
A/YKL1jo4Effawz67FXQwYKHhbbnNfo9PHF0gJMdnDzHzQ4OnuNgFwe7faLkNXo438O5Dt6BqdEN
9lq/LbKqs6sW3LqT/L9CLZ8gyl7Zxx8P+1AEKQYTg87Ta3r9e7F2ehXGrldh6wQlJp+YERiYqUTh
dzoV23b/HlVVHe2BqnzqeaslSiZca04tMetsce20wHixA+QOZGMngbFB929ipO8yw41beKGFb8sc
XNQLdQxisHImNlxa7Cq9c/c/PyKMo3KrRfRbJa8d3uX4wdh2hWBEqC80AUY8tbXrjfqQ8Z//gvuR
3e349c89fr/88A+v2e/cscdo2sOBv/6t3fQ/LQ8Qojs4v+DpdKHnlu93WoU//8BXG8ZB/37GA/9B
xn6z8zDjywwDoM4t46c6Uxum7fYD0t4FiC3Qyn/mNXsPM3zNk/Tf/7T8voyg3uJqw9If3MfSb3rB
g3IGtqk8You3XVvjdeuGj6kam6lpUzk249P/2H/ZvtJKD7HaA6+VqrqOfpOjk2KIzaoBQfWv265t
LyapFmJgkUlV2RvoUdN0kSEzoPzn9JX7sYX8Kwz/mBtrNH6j093DkyXos6hb2wJK0N/tNWCNgyre
sP9/i2ooTGToJYXQj24uMjfXAtRFDQMaS9QaJNFcoIPUDDYH2aXUKkupX6AuYfPvt3IYpIkNAxdN
V1lI6sN0Bqo4jYbuMsuod6XpUaOPfUw3UTfp4/JzyPEXC2a/cFw4v/2Ty2j7kW0zGU9++ju6zKDH
7vj/5dNv2U//Yr8X8oPQxRwCxYYFHb/BLtOiTGZbgewkvvtJYMnDtf0kQD/ssL/Zxd0UzvyeHvs7
heFmga139rm/V43klKPtj/IDguVffwioVIj36itQq/zv838B5uKy8o4eAAA=
RWTPL1
    ;;
    2) cat <<'RWTPL2'
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
/+v6NwJqP0z8GgAA
RWTPL2
    ;;
    3) cat <<'RWTPL3'
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
RWTPL3
    ;;
    4) cat <<'RWTPL4'
H4sIAAAAAAAC/+1Z627byhH+76fYMjhAW1gySV0sU7IAnyQFUpw0QezgoD+X3KG4xxSX3V3KVg0D
fYf2Xfq/j9In6czyopsvSU7yI8UBBJFc7mXm+2ZmZ5az37169/Lqr+9fs8wu8/nRjC4s58Xi3IPC
owbgAi9LsJwlGdcG7LlX2bQ38drmgi/h3FtJuCmVth5LVGGhwG43UtjsXMBKJtBzD8eykFbyvGcS
nsN5QHNYaXOYv9OxtOwtlzn77z/+xS5B0yhmLLeVmZ3UnXYWFGASLUsrVbG15stKa7xhqgTN6R3P
m0kYLwSTRSIFvc+ksUqvWao021rbal4YnjQDYUltskg1N1ZXia009ElmY9ckzh/vYnXbM/LvslhE
sdICdA9bpkuuF7KI/GnJhaB3/v1RrMT6LubJ9UKrqhDRi/Q0naR8mqhc6ehFkITDQTBNUY8oGJW3
J0F/zHq8LHPombWxsDz+MZfF9VueXLrHP2HPY+8SFgrYxzfe8QcVK6uOLzTCe2xQi54BLdP7o/6N
5uXdkt/WFEST0C83IjJeWbWRk9HL+yNiHfSuuGk67VS0Vi2joLxlRuVSsBcwgFMAXCuLub4T0pQ5
X0dpDrdTnstF0ZMosYkSRB709JfKWJmuew1pkSk5GkgM9gagmGYgF5mNRhMSpB8jIeLZGRe8jM5Q
K4Kvd1NPMPb9+hn5AYdpIx/jdw3oo3g8Pp1MLdzanoBE1RYTFaqA7aHDDq9eDqmNwrAWjRfFHkgw
SccgGpy2AYpPIUxOWwA1F7IyEWrYIR/gA9tmJqQGf/opmgeDLXlYfLcl+nj7DeJctKoP+TgenW5r
OegjRN16ca6S61Zrq8qo1lkoe1ebUYDatVy5+13dRv4PU5LZgYkD1fUOUGHIhyNx37/huthF0OeB
f3qPIouddnE29AccJ0IdIH/EMg9N8gHE1Qp0mqubKJMCQ0GrY2PUYY2YW4Vl4TaWiHJtKi5IYOBY
RlWJYSbhBqY5WKSjR6ZMdPb9U1hOd82so3rYUv2MPx2Y847WcZqkAkU1q+RXetznCAZpkI5qqxs6
pHD5KMfw2EsymSNnOyP9ugPrU8j+JC8O/NaNG9/rjxoT1mZ3AuqNRrkzEb3oQSF2TI+GMnm3a9m1
EQ82NkxOvWctzqoPjbadsS8esVz38vYR803sXvTZszD3uOIYxvFaVEsM4klkeVzlXNOzaUQfjVtz
dABEmrTY0Rv3urvD8PIMtfW4pxnFDiwb3O0G1z0/qkMS9ezfZNCFnUl8NuKjbZ3D/uHgwO9Gl3d7
gbiNX/4wHiV7407dMMsXHdmywE0TLd1xvjVT8Fm+PEJfbpFEM2GnB6aytUU4IkiUKQYaKzHRaRgK
aul6GsxDm0ajWBiOB4P0Hvst1W5oTEU6EEnbb8LHQ5/YyGEB+1vk0/7+OBfbG1LQWcxB1GmVp33h
AQtKlUL8Otsb+LSTsbG/Ye9w6cHW3vMJKjhHp8Qmor86crgdql57s8U3Kz24xW/v6YFLN2YnTWY3
O2kSX0rbmjQY9Hwm5Iol6BwGs1tc2NtpoeQCs0PGthtdAuNasd2sFqzOir3Q91gdeup7yp9/VLfn
ns8oC8MfTp5IneTAEmwOsE+yrq/63Bv0hx5LZZ6fey/CdJyC8E7mM8hzWZoHBuDzGV7wcbgZSCB4
mB1rdY35dANV29Br5Az6A491XnLuaYXZNPy+F05Y4OPvD7TuCSpWq7jJpQmHEwSiBaSBgLNMQ4rL
CZUYb/5KJRjjCutomZ3w/V4G3ZKqivllffNgl5gqgRioU3PLrGJVKVBS04xoZKkv7X9D69HRIbH7
NLoUquMR84P2DaZETF17BAK2Nh3c9PH8Isfqw6XrZrsimZ3EczfH/CeMs1hXQXINggVjdlEt0O6R
/HDMuGV+iEGPfbx6yf7z71YfBhhX1uhOzKA9F8I0C2/Arm/2FHAZTSt/Fs7bQqmtsLCpE70dg1v3
roXTNu7Nn1L/8u3Ve6YB3djVca8/dmLtT077JA6TOFL+X10eUxi3fm8e+P4P2zb4DTD/ePnNMO8E
8L5P9M/O+mfDr47/h9eXV+zi/ZvfTP2bm/rPEGdKXZuvAXU75Nb7fqz782z9NPjqBLziJosV1+I3
Y//mxv6miCnrZiUiion0d4X4V/alZ6P65Gn06yKpgXs+8Jnga8P4QrXJk/u/Utj8ZenUm72D5YcT
KqxovU6NbLDLPtatzFWH3vwDYEm1AtHI8jqHFaZ+gt3U4Y8JyKXLAnNsLhJabfAQPFR6k23u5JWY
SgbDKAwxWfgn5pyRP2ozzCBjw8FyF+xyfkGn66lcVHX6Sp8BioXLsG0GmHdYlONvFVRYdvDKHEop
MWfFzpiUG8x0RZVTF2kzhqojIArz0MQyqjJVmh7jhKbKLdo7vqQpiCiVYvZLkwAiAQVbyqKiVJhO
73lZanUrl4hEvmbDH6gzcl0qWVjTZ39RlDDjLYqlgeXK2P7spNzS7wq1aHS64YZplZOEJA+l4MEo
GkwcQPT9gDSudRWaywL7pVWOy8brGsk++xlYxlfAsPjFt5zy6wUpg3zQcQDih79GWeb826FTaicl
DkA0XGqewEbOR6z6C83pPdf0EYa5vFHAQnPhmD3G1BGXX7hK7CmDwtrvzxVq3ZqTP4iCwJkT3g3P
WnMaTA5s6V0BxE+qKt1krIUSSCRSXZkeUDWUYu2IyGFplqONuNoIPTV1VT27Bk0Hs1VJQoOjxHEG
S7UiMrRaMlehEtD0aQPNgo5g8nWfXWVaVYusrCySp8qSSF4z14a6cOQVcQE9RZHYEozhC2iMRsMv
aKIgjmvuHZ2xUTqG2iKETFP4ppRddp6zRLNDn+e4mMv2kToec6z5CTc622boGPaZgDDc4y+IfL/m
L4hCv+Uv9A/4e59THSw2i8Et6ETSkYNaljlQkEI+Okfvsy5haIjioqeKvP7w5rBrwsoUy9lCOGiR
VMyma+irgiO2BP4D0H5aaP5Yomw08RZ0Xxyelwrx69ho2Ln66ZIl5N0p2pqFzgKPGVpe41HmGZcK
92M01v4tKWE0cKTss/Fys2YdC2cJetPcLG3ZV3QQQ98v+xI3OdfukK278FI+2ONGosBxowHR9zKX
LnjaDGNhiW5KnOXA0x2FTaaqXDQnFOTMXKwI5qnrTqjrJQhJL0kGrTDR4Y7dOvA+QW7L8aw+2Ts8
gmPuyA4zjV99eticrFMq153/7H+Ybr4llxgciCQ64LESo8UOPfXxT3dApQ059OUlnURtWjkGJ29+
gf977aVEC6uXcUUln++dXTVI4HNzOnlSf73/HziO6fvOHwAA
RWTPL4
    ;;
    *) return 1 ;;
  esac
}

list_templates() {
  echo "Доступные заглушки:"
  local i
  for ((i=1; i<=TEMPLATE_COUNT; i++)); do
    printf "  %d  %s\n" "$i" "$(template_name "$i")"
  done
  echo
  echo "Выбор: -t N. Без флага берётся случайная."
  echo "Ставьте разные заглушки на разные ноды: одинаковая страница"
  echo "на нескольких IP — готовый признак для массового сканирования."
}

install_template() {
  if [[ -z "$TEMPLATE" ]]; then
    TEMPLATE=$(( (RANDOM % TEMPLATE_COUNT) + 1 ))
    info "заглушка выбрана случайно"
  fi
  [[ "$TEMPLATE" =~ ^[0-9]+$ ]] && (( TEMPLATE >= 1 && TEMPLATE <= TEMPLATE_COUNT )) \
    || die "Шаблон должен быть числом от 1 до $TEMPLATE_COUNT"

  if [[ $DRY_RUN -eq 1 ]]; then
    info "[dry-run] заглушка $TEMPLATE: $(template_name "$TEMPLATE") -> $WWW_ROOT/index.html"
    return
  fi

  mkdir -p "$WWW_ROOT"
  if [[ -f "$WWW_ROOT/index.html" ]]; then
    backup "$WWW_ROOT/index.html"
  fi
  template_data "$TEMPLATE" | base64 -d | gunzip > "$WWW_ROOT/index.html" \
    || die "Не удалось распаковать заглушку"
  chown -R www-data:www-data "$WWW_ROOT" 2>/dev/null || true
  chmod -R 755 "$WWW_ROOT"
  ok "заглушка $TEMPLATE: $(template_name "$TEMPLATE")"
}

# ---------------------------------------------------------------- параметры

DOMAIN=""
EMAIL=""
PANEL_IP=""
NODE_PORT=""
NODE_DIR=""
XPATH=""
TEMPLATE=""
MODE=""
ASSUME_YES=0
DRY_RUN=0
DO_UFW=1
DO_SYSCTL=1
DO_CERT=1
WWW_ROOT="/var/www/selfsteal"
NGINX_SOCK="/dev/shm/nginx.sock"
XRAY_SOCK="/dev/shm/xrxh.socket"
STATE_DIR="/etc/rw-node-setup"

usage() {
cat <<EOF
${C_BOLD}rw-node-setup.sh${C_0} v$VERSION — Selfsteal + XHTTP для ноды Remnawave

${C_BOLD}ИСПОЛЬЗОВАНИЕ${C_0}
  $SELF install     -d ДОМЕН -e EMAIL [опции]   полная установка
  $SELF add-xhttp   -d ДОМЕН [опции]            только XHTTP к готовому nginx
  $SELF status      [-d ДОМЕН]                  проверить состояние
  $SELF uninstall   -d ДОМЕН                    убрать nginx-часть

${C_BOLD}ОПЦИИ${C_0}
  -d, --domain DOMAIN     домен ноды, A-запись должна вести на этот сервер
  -e, --email EMAIL       адрес для Let's Encrypt
  -p, --panel-ip IP       IP панели, откроется доступ к порту ноды в ufw
  -n, --node-port PORT    порт ноды (по умолчанию берётся из docker-compose)
      --node-dir PATH     каталог remnanode (по умолчанию ищется сам)
      --path PATH         путь XHTTP, например /xh-a1b2c3d4/ (по умолчанию случайный)
  -t, --template N        заглушка 1-$TEMPLATE_COUNT (по умолчанию случайная)
      --list-templates    показать список заглушек и выйти
      --no-ufw            не трогать фаервол
      --no-sysctl         не трогать sysctl
      --no-cert           не выпускать сертификат (уже есть)
  -y, --yes               не задавать вопросов
      --dry-run           показать, что будет сделано, ничего не менять
  -h, --help              эта справка

${C_BOLD}ПРИМЕРЫ${C_0}
  $SELF install -d pl3.example.org -e me@example.org -p 203.0.113.10 -y
  $SELF add-xhttp -d pl1.example.org
  $SELF status -d pl3.example.org

${C_BOLD}ЧТО ДЕЛАЕТ install${C_0}
  1. проверки: root, домен, порты, docker, нода
  2. sysctl: BBR и буферы UDP
  3. nginx + certbot
  4. заглушка в $WWW_ROOT
  5. сертификат Let's Encrypt через webroot по порту 80
  6. боевой конфиг: unix-сокет + proxy_protocol + http2 + location для XHTTP
  7. hook на обновление сертификата
  8. проброс /dev/shm в контейнер ноды, пересоздание контейнера
  9. ufw
  10. печать Config Profile и параметров Host для панели

${C_BOLD}ЧЕГО НЕ ДЕЛАЕТ${C_0}
  Не трогает панель Remnawave: профиль и хосты создаёте вы.
  Не создаёт DNS-записи и не выключает прокси Cloudflare.

${C_BOLD}ОТКАТ${C_0}
  Конфиги nginx бэкапятся в $STATE_DIR перед изменением.
  docker-compose ноды — в тот же каталог, с меткой времени.
  $SELF uninstall убирает конфиг nginx, заглушку и hook; ноду и
  сертификаты не трогает.
EOF
}

# ---------------------------------------------------------------- разбор аргументов

[[ $# -eq 0 ]] && { usage; exit 0; }

case "${1:-}" in
  install|add-xhttp|status|uninstall) MODE="$1"; shift ;;
  -h|--help) usage; exit 0 ;;
  --list-templates) list_templates; exit 0 ;;
  *) die "Неизвестная команда: $1. Смотрите $SELF --help" ;;
esac

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--domain)     DOMAIN="${2:-}"; shift 2 ;;
    -e|--email)      EMAIL="${2:-}"; shift 2 ;;
    -p|--panel-ip)   PANEL_IP="${2:-}"; shift 2 ;;
    -n|--node-port)  NODE_PORT="${2:-}"; shift 2 ;;
    --node-dir)      NODE_DIR="${2:-}"; shift 2 ;;
    --path)          XPATH="${2:-}"; shift 2 ;;
    -t|--template)   TEMPLATE="${2:-}"; shift 2 ;;
    --list-templates) list_templates; exit 0 ;;
    --no-ufw)        DO_UFW=0; shift ;;
    --no-sysctl)     DO_SYSCTL=0; shift ;;
    --no-cert)       DO_CERT=0; shift ;;
    -y|--yes)        ASSUME_YES=1; shift ;;
    --dry-run)       DRY_RUN=1; shift ;;
    -h|--help)       usage; exit 0 ;;
    *) die "Неизвестный параметр: $1" ;;
  esac
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  %s[dry-run]%s %s\n' "$C_D" "$C_0" "$*"
  else
    "$@"
  fi
}

write_file() {
  # write_file ПУТЬ <<< содержимое
  local path="$1" content; content="$(cat)"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  %s[dry-run]%s записать %s (%s строк)\n' "$C_D" "$C_0" "$path" "$(wc -l <<<"$content")"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

confirm() {
  [[ $ASSUME_YES -eq 1 || $DRY_RUN -eq 1 ]] && return 0
  local a; read -rp "  ? $1 [y/N] " a
  [[ "$a" =~ ^[Yy]$ ]]
}

backup() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  mkdir -p "$STATE_DIR/backup"
  local dst="$STATE_DIR/backup/$(basename "$f").$(date +%Y%m%d-%H%M%S)"
  run cp -a "$f" "$dst"
  info "бэкап: $dst"
}

# ---------------------------------------------------------------- проверки

need_root() { [[ $EUID -eq 0 ]] || die "Нужны права root. Запустите через sudo."; }

check_os() {
  [[ -f /etc/os-release ]] || die "Не удалось определить дистрибутив."
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
    *debian*|*ubuntu*) ok "ОС: ${PRETTY_NAME:-$ID}" ;;
    *) die "Поддерживаются только Debian и Ubuntu. Найдено: ${PRETTY_NAME:-$ID}" ;;
  esac
}

server_ip() {
  ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}'
}

resolve_domain() {
  getent ahostsv4 "$1" 2>/dev/null | awk 'NR==1{print $1}'
}

check_domain() {
  [[ -n "$DOMAIN" ]] || die "Укажите домен: -d ДОМЕН"
  [[ "$DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]] || die "Домен выглядит некорректно: $DOMAIN"

  local mine resolved
  mine="$(server_ip || true)"
  resolved="$(resolve_domain "$DOMAIN" || true)"

  [[ -n "$resolved" ]] || die "Домен $DOMAIN не резолвится. Создайте A-запись на $mine и подождите."

  case "$resolved" in
    104.1[6-9].*|104.2[0-7].*|172.6[4-9].*|172.7[0-1].*|162.159.*|188.114.*|198.41.*|173.245.*|103.21.24[4-7].*)
      err "Домен $DOMAIN резолвится в $resolved — это адрес Cloudflare."
      err "Включён режим Proxied (оранжевая тучка). REALITY за ним не работает в принципе:"
      err "Cloudflare терминирует TLS у себя, и Xray не увидит рукопожатие клиента."
      die  "Переключите запись в DNS only и повторите."
      ;;
  esac

  if [[ -n "$mine" && "$resolved" != "$mine" ]]; then
    warn "Домен резолвится в $resolved, а адрес сервера $mine."
    warn "Если это не проброс через NAT — сертификат выпустить не удастся."
    confirm "Продолжить всё равно?" || die "Прервано."
  else
    ok "Домен $DOMAIN -> $resolved"
  fi
}

check_ports() {
  local busy=0 l
  for p in 80 443; do
    if l="$(ss -tlnp 2>/dev/null | awk -v P=":$p" '$4 ~ P"$" {print; exit}')"; then
      [[ -n "$l" ]] || continue
      if [[ "$p" == 443 ]] && grep -qE 'xray|rw-core' <<<"$l"; then
        ok "порт 443/tcp занят Xray — так и должно быть"
      else
        warn "порт $p/tcp занят: $l"
        busy=1
      fi
    fi
  done
  if [[ $busy -eq 1 ]]; then
    warn "Освободите порт 80 (обычно это забытый Caddy или другой nginx)."
    confirm "Продолжить?" || die "Прервано."
  fi
}

find_node_dir() {
  [[ -n "$NODE_DIR" ]] && { [[ -f "$NODE_DIR/docker-compose.yml" ]] || die "В $NODE_DIR нет docker-compose.yml"; return; }
  local c
  for c in /opt/remnanode /root/remnanode /opt/remnawave-node "$HOME/remnanode"; do
    [[ -f "$c/docker-compose.yml" ]] && { NODE_DIR="$c"; return; }
  done
  c="$(grep -rls 'remnawave/node' /opt /root /srv --include=docker-compose.yml 2>/dev/null | head -1 || true)"
  [[ -n "$c" ]] && { NODE_DIR="$(dirname "$c")"; return; }
  die "Не нашёл каталог ноды. Укажите явно: --node-dir /путь"
}

find_node_port() {
  [[ -n "$NODE_PORT" ]] && return
  NODE_PORT="$(ss -tlnp 2>/dev/null | awk '/rw-node/ {split($4,a,":"); print a[length(a)]; exit}' || true)"
  [[ -n "$NODE_PORT" ]] && { ok "порт ноды $NODE_PORT (по слушающему сокету)"; return; }
  NODE_PORT="$(grep -oP 'NODE_PORT\s*=\s*\K[0-9]+' "$NODE_DIR/docker-compose.yml" 2>/dev/null | head -1 || true)"
  [[ -n "$NODE_PORT" ]] && { ok "порт ноды $NODE_PORT (из docker-compose)"; return; }
  warn "Порт ноды определить не удалось — правило ufw для панели создано не будет."
}

check_docker() {
  command -v docker >/dev/null || die "Docker не установлен."
  docker ps >/dev/null 2>&1 || die "Docker не отвечает. Проверьте: systemctl status docker"
  docker ps --format '{{.Names}}' | grep -qx remnanode \
    || warn "Контейнер remnanode не запущен — ключи REALITY придётся сгенерировать иначе."
}

# ---------------------------------------------------------------- nginx

nginx_conf_target() {
  # куда класть server-блок: sites-available или conf.d
  if grep -qE '^\s*include\s+/etc/nginx/sites-enabled/\*' /etc/nginx/nginx.conf 2>/dev/null; then
    echo "sites"
  else
    echo "confd"
  fi
}

nginx_http2_line() {
  # nginx >= 1.25.1 понимает "http2 on;", более старые — только параметр listen
  local v; v="$(nginx -v 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 0.0.0)"
  local maj min pat; IFS=. read -r maj min pat <<<"$v"
  if (( maj > 1 )) || { (( maj == 1 )) && (( min > 25 )); } \
     || { (( maj == 1 )) && (( min == 25 )) && (( pat >= 1 )); }; then
    echo "modern"
  else
    echo "legacy"
  fi
}

conf_path() {
  if [[ "$(nginx_conf_target)" == "sites" ]]; then
    echo "/etc/nginx/sites-available/selfsteal-$DOMAIN"
  else
    echo "/etc/nginx/conf.d/selfsteal-$DOMAIN.conf"
  fi
}

enable_conf() {
  local p="$1"
  if [[ "$(nginx_conf_target)" == "sites" ]]; then
    run ln -sf "$p" "/etc/nginx/sites-enabled/$(basename "$p")"
  fi
  run rm -f /etc/nginx/sites-enabled/default
}

nginx_temp_conf() {
  write_file "$(conf_path)" <<EOF
# создано rw-node-setup.sh, временный конфиг под выпуск сертификата
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    location /.well-known/acme-challenge/ { root $WWW_ROOT; }
    location / { return 301 https://\$host\$request_uri; }
}
EOF
}

nginx_final_conf() {
  local listen_line http2_line
  if [[ "$(nginx_http2_line)" == "modern" ]]; then
    listen_line="listen unix:$NGINX_SOCK ssl proxy_protocol;"
    http2_line="    http2 on;"
  else
    listen_line="listen unix:$NGINX_SOCK ssl http2 proxy_protocol;"
    http2_line=""
  fi

  write_file "$(conf_path)" <<EOF
# создано rw-node-setup.sh $(date +%F) для $DOMAIN
# XHTTP path: $XPATH

server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    location /.well-known/acme-challenge/ { root $WWW_ROOT; }
    location / { return 301 https://\$host\$request_uri; }
}

server {
    $listen_line
$http2_line
    server_name $DOMAIN;

    # реальный IP клиента приходит от Xray через PROXY protocol (xver: 1)
    set_real_ip_from unix:;
    real_ip_header  proxy_protocol;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 1d;

    root  $WWW_ROOT;
    index index.html;

    client_header_timeout 5m;
    keepalive_timeout     5m;

    # логи с реальными IP пользователей для VPN-ноды не нужны
    access_log off;
    error_log  /var/log/nginx/selfsteal-error.log warn;

    location $XPATH {
        client_max_body_size 0;
        client_body_timeout  5m;
        grpc_read_timeout    315;
        grpc_send_timeout    5m;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_pass unix:$XRAY_SOCK;
    }

    location / { try_files \$uri \$uri/ /index.html; }
}
EOF
}

nginx_reload() {
  if [[ $DRY_RUN -eq 1 ]]; then info "[dry-run] nginx -t && systemctl restart nginx"; return; fi
  nginx -t >/dev/null 2>&1 || { nginx -t; die "Конфиг nginx не проходит проверку."; }
  systemctl restart nginx
  sleep 1
  systemctl is-active --quiet nginx || die "nginx не запустился. Смотрите: journalctl -u nginx -n 40"
}

verify_conf_included() {
  [[ $DRY_RUN -eq 1 ]] && return 0
  local n; n="$(nginx -T 2>/dev/null | grep -c "server_name $DOMAIN" || true)"
  (( n > 0 )) || die "Конфиг создан, но nginx его не читает. Проверьте include в /etc/nginx/nginx.conf"
  ok "конфиг подключён (nginx -T видит $DOMAIN)"
}

# ---------------------------------------------------------------- сертификат

issue_cert() {
  if [[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]]; then
    ok "сертификат уже есть, выпуск пропущен"
    return
  fi
  [[ -n "$EMAIL" ]] || die "Для выпуска сертификата нужен -e EMAIL (или --no-cert)"
  run certbot certonly --webroot -w "$WWW_ROOT" -d "$DOMAIN" \
      --agree-tos --no-eff-email --non-interactive -m "$EMAIL"
  [[ $DRY_RUN -eq 1 ]] && return
  [[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]] || die "certbot отработал, но сертификата нет."
  ok "сертификат выпущен"
}

deploy_hook() {
  local h=/etc/letsencrypt/renewal-hooks/deploy/rw-node-reload.sh
  write_file "$h" <<'EOF'
#!/bin/bash
# Xray читает сертификат только при старте, поэтому ноду надо перезапустить
systemctl reload nginx 2>/dev/null || true
docker restart remnanode 2>/dev/null || true
EOF
  run chmod +x "$h"
  ok "hook на обновление сертификата: $h"
}

# ---------------------------------------------------------------- нода

patch_compose() {
  local f="$NODE_DIR/docker-compose.yml"
  if grep -qE '^\s*-\s*/dev/shm:/dev/shm\s*$' "$f"; then
    ok "/dev/shm уже проброшен в контейнер ноды"
    return
  fi
  backup "$f"
  if [[ $DRY_RUN -eq 1 ]]; then info "[dry-run] добавить том /dev/shm в $f"; return; fi

  python3 - "$f" <<'PY'
import sys, re
path = sys.argv[1]
lines = open(path, encoding='utf-8').read().split('\n')

# найти строку сервиса remnanode
svc = None
for i, l in enumerate(lines):
    if re.match(r'^\s*remnanode\s*:\s*$', l):
        svc = i; break
if svc is None:
    sys.exit('remnanode: не найден в docker-compose.yml')

svc_indent = len(lines[svc]) - len(lines[svc].lstrip())
body_indent = None
end = len(lines)
for i in range(svc + 1, len(lines)):
    s = lines[i].strip()
    if not s or s.startswith('#'):
        continue
    ind = len(lines[i]) - len(lines[i].lstrip())
    if ind <= svc_indent:
        end = i; break
    if body_indent is None:
        body_indent = ind

body_indent = body_indent if body_indent is not None else svc_indent + 2
item_indent = body_indent + 2

# есть ли volumes внутри сервиса
vol = None
for i in range(svc + 1, end):
    if re.match(r'^\s{%d}volumes\s*:\s*$' % body_indent, lines[i]):
        vol = i; break

entry = ' ' * item_indent + '- /dev/shm:/dev/shm'
if vol is not None:
    lines.insert(vol + 1, entry)
else:
    while end > svc + 1 and not lines[end - 1].strip():
        end -= 1
    lines.insert(end, ' ' * body_indent + 'volumes:')
    lines.insert(end + 1, entry)

open(path, 'w', encoding='utf-8').write('\n'.join(lines))
print('ok')
PY

  ( cd "$NODE_DIR" && docker compose config -q ) \
    || die "После правки docker-compose.yml он стал невалидным. Восстановите из $STATE_DIR/backup"
  ok "том /dev/shm добавлен"
}

recreate_node() {
  if [[ $DRY_RUN -eq 1 ]]; then info "[dry-run] docker compose up -d --force-recreate"; return; fi
  ( cd "$NODE_DIR" && docker compose up -d --force-recreate >/dev/null )
  sleep 3
  docker exec remnanode ls /dev/shm >/dev/null 2>&1 \
    && ok "контейнер пересоздан, /dev/shm виден изнутри" \
    || warn "контейнер пересоздан, но /dev/shm изнутри не читается"
}

# ---------------------------------------------------------------- система

setup_sysctl() {
  [[ $DO_SYSCTL -eq 1 ]] || { info "sysctl пропущен по --no-sysctl"; return; }
  write_file /etc/sysctl.d/99-rw-node.conf <<'EOF'
# создано rw-node-setup.sh
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.somaxconn = 8192
fs.file-max = 1000000
EOF
  run sysctl --system >/dev/null
  if [[ $DRY_RUN -eq 0 ]]; then
    local cc; cc="$(sysctl -n net.ipv4.tcp_congestion_control)"
    [[ "$cc" == "bbr" ]] && ok "BBR включён" || warn "congestion control = $cc, BBR не применился"
  fi
}

setup_ufw() {
  [[ $DO_UFW -eq 1 ]] || { info "ufw пропущен по --no-ufw"; return; }
  command -v ufw >/dev/null || { warn "ufw не установлен, фаервол пропущен"; return; }
  run ufw allow 22/tcp    >/dev/null
  run ufw allow 80/tcp    >/dev/null
  run ufw allow 443/tcp   >/dev/null
  if [[ -n "$PANEL_IP" && -n "$NODE_PORT" ]]; then
    run ufw allow from "$PANEL_IP" to any port "$NODE_PORT" proto tcp >/dev/null
    ok "порт ноды $NODE_PORT открыт только для $PANEL_IP"
  elif [[ -n "$NODE_PORT" ]]; then
    warn "IP панели не задан (-p), порт ноды $NODE_PORT в ufw не открыт"
    warn "без этого правила нода будет отваливаться из панели"
  fi
  run ufw --force enable >/dev/null
  ok "ufw настроен"
}

# ---------------------------------------------------------------- ключи

gen_path() { echo "/xh-$(openssl rand -hex 4)/"; }
gen_shortid() { openssl rand -hex 8; }

gen_reality_keys() {
  local out=""
  if docker ps --format '{{.Names}}' | grep -qx remnanode; then
    out="$(docker exec remnanode xray x25519 2>/dev/null || true)"
  fi
  if [[ -z "$out" ]]; then
    out="$(docker run --rm ghcr.io/xtls/xray-core:latest x25519 2>/dev/null || true)"
  fi
  [[ -n "$out" ]] || die "Не удалось сгенерировать ключи REALITY. Запустите ноду и повторите."
  RK_PRIV="$(grep -iE 'private' <<<"$out" | awk -F': *' '{print $2}' | tr -d '[:space:]')"
  RK_PUB="$(grep -iE 'public|password' <<<"$out" | awk -F': *' '{print $2}' | tr -d '[:space:]')"
  [[ -n "$RK_PRIV" && -n "$RK_PUB" ]] || die "Не разобрал вывод xray x25519:\n$out"
}

# ---------------------------------------------------------------- вывод результата

save_state() {
  mkdir -p "$STATE_DIR"
  write_file "$STATE_DIR/$DOMAIN.env" <<EOF
DOMAIN=$DOMAIN
XPATH=$XPATH
REALITY_PUBLIC=$RK_PUB
SHORTID_1=$SID1
SHORTID_2=$SID2
NODE_DIR=$NODE_DIR
NODE_PORT=$NODE_PORT
TEMPLATE=$TEMPLATE
CREATED=$(date -Iseconds)
EOF
  run chmod 600 "$STATE_DIR/$DOMAIN.env"
}

print_result() {
  cat <<EOF

${C_BOLD}================================================================${C_0}
${C_BOLD} Серверная часть готова. Дальше — панель, вручную.${C_0}
${C_BOLD}================================================================${C_0}

${C_BOLD}1. Config Profile${C_0}  (Nodes -> нода -> Config Profile, вставить целиком)

$(profile_json)

${C_BOLD}2. Host — REALITY${C_0}

  Inbound          VLESS_SELFSTEAL
  Адрес            $DOMAIN
  Порт             443
  Security Layer   По умолчанию
  SNI              $DOMAIN
  Отпечаток        chrome
  Flow             xtls-rprx-vision
  ALPN             пусто

${C_BOLD}3. Host — XHTTP${C_0}

  Inbound          XHTTP
  Адрес            $DOMAIN
  Порт             443
  Security Layer   TLS
  SNI              $DOMAIN
  Путь             $XPATH
  ALPN             h2
  Отпечаток        chrome
  Mode             stream-up   (блок "Xray Json & Raw" -> кнопка xHTTP)
  Flow             ПУСТО — Vision несовместим с XHTTP

${C_BOLD}4. Проверка после сохранения профиля${C_0}

  ls -la /dev/shm/
      ждём nginx.sock и xrxh.socket с правами srw-rw-rw-

  curl -i https://$DOMAIN$XPATH
      ждём 400 и заголовок x-padding — это подпись XHTTP-инбаунда Xray
      200 с заглушкой = пути разошлись; 502 = сокет недоступен

${C_D}Публичный ключ REALITY и short ID панель берёт из профиля сама.
Параметры сохранены в $STATE_DIR/$DOMAIN.env${C_0}

EOF
}

profile_json() {
cat <<EOF
{
  "log": { "loglevel": "warning" },
  "dns": { "servers": ["1.1.1.1", "1.0.0.1"], "queryStrategy": "UseIP" },
  "inbounds": [
    {
      "tag": "VLESS_SELFSTEAL",
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": { "clients": [], "decryption": "none" },
      "sniffing": { "enabled": true, "destOverride": ["http","tls","quic"], "routeOnly": true },
      "streamSettings": {
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "target": "$NGINX_SOCK",
          "xver": 1,
          "spiderX": "",
          "serverNames": ["$DOMAIN"],
          "privateKey": "$RK_PRIV",
          "shortIds": ["$SID1", "$SID2"]
        }
      }
    },
    {
      "tag": "XHTTP",
      "listen": "$XRAY_SOCK,0666",
      "protocol": "vless",
      "settings": { "clients": [], "decryption": "none" },
      "sniffing": { "enabled": true, "destOverride": ["http","tls","quic"], "routeOnly": true },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {
          "mode": "stream-up",
          "path": "$XPATH",
          "extra": {
            "noSSEHeader": true,
            "scMaxBufferedPosts": 30,
            "scMaxEachPostBytes": 1000000,
            "scMinPostsIntervalMs": 30,
            "scStreamUpServerSecs": 40,
            "xPaddingBytes": "100-1000"
          }
        }
      }
    }
  ],
  "outbounds": [
    { "tag": "DIRECT", "protocol": "freedom", "settings": { "domainStrategy": "UseIPv4" } },
    { "tag": "BLOCK", "protocol": "blackhole" }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      { "type": "field", "ip": ["geoip:private"], "outboundTag": "BLOCK" },
      { "type": "field", "domain": ["geosite:private"], "outboundTag": "BLOCK" },
      { "type": "field", "protocol": ["bittorrent"], "outboundTag": "BLOCK" },
      { "type": "field", "domain": ["geosite:category-ads-all"], "outboundTag": "BLOCK" },
      { "type": "field", "network": "tcp,udp", "outboundTag": "DIRECT" }
    ]
  }
}
EOF
}

# ---------------------------------------------------------------- команды

cmd_install() {
  need_root
  step "Проверки"
  check_os; check_domain; check_ports; check_docker
  find_node_dir; ok "нода: $NODE_DIR"; find_node_port

  [[ -n "$XPATH" ]] || XPATH="$(gen_path)"
  [[ "$XPATH" == /* ]] || XPATH="/$XPATH"
  [[ "$XPATH" == */ ]] || XPATH="$XPATH/"
  SID1="$(gen_shortid)"; SID2="$(gen_shortid)"

  step "Системные параметры"
  setup_sysctl

  step "Установка nginx и certbot"
  run env DEBIAN_FRONTEND=noninteractive apt-get update -qq
  run env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx certbot openssl >/dev/null
  ok "nginx $(nginx -v 2>&1 | grep -oE '[0-9.]+' || echo '?'), синтаксис http2: $(nginx_http2_line)"

  step "Сайт-заглушка"
  install_template

  step "Временный конфиг nginx и сертификат"
  backup "$(conf_path)"
  nginx_temp_conf; enable_conf "$(conf_path)"; nginx_reload; verify_conf_included
  [[ $DO_CERT -eq 1 ]] && issue_cert || info "выпуск сертификата пропущен по --no-cert"
  deploy_hook

  step "Ключи REALITY"
  gen_reality_keys
  ok "ключи сгенерированы (уникальные для этой ноды)"

  step "Боевой конфиг nginx"
  nginx_final_conf; nginx_reload; verify_conf_included
  [[ $DRY_RUN -eq 0 ]] && { [[ -S "$NGINX_SOCK" ]] && ok "сокет $NGINX_SOCK создан" || die "сокет $NGINX_SOCK не появился"; }

  step "Проброс /dev/shm в контейнер ноды"
  patch_compose; recreate_node

  step "Фаервол"
  setup_ufw

  step "Проверка"
  verify_all

  save_state
  print_result
}

cmd_add_xhttp() {
  need_root
  [[ -n "$DOMAIN" ]] || die "Укажите домен: -d ДОМЕН"
  step "Проверки"
  check_os; check_docker; find_node_dir; ok "нода: $NODE_DIR"

  local cf; cf="$(grep -rl "server_name  *$DOMAIN" /etc/nginx/ 2>/dev/null | head -1 || true)"
  [[ -n "$cf" ]] || die "Не нашёл server-блок для $DOMAIN в /etc/nginx. Если nginx в Docker — правьте конфиг вручную, см. документацию."
  ok "конфиг: $cf"

  if grep -q "grpc_pass unix:$XRAY_SOCK" "$cf"; then
    ok "location для XHTTP уже есть, повторно не добавляю"
  else
    [[ -n "$XPATH" ]] || XPATH="$(gen_path)"
    [[ "$XPATH" == */ ]] || XPATH="$XPATH/"
    backup "$cf"
    if [[ $DRY_RUN -eq 0 ]]; then
      python3 - "$cf" "$XPATH" "$XRAY_SOCK" <<'PY'
import sys, re
path, xpath, sock = sys.argv[1], sys.argv[2], sys.argv[3]
src = open(path, encoding='utf-8').read()
block = f"""
    location {xpath} {{
        client_max_body_size 0;
        client_body_timeout  5m;
        grpc_read_timeout    315;
        grpc_send_timeout    5m;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_pass unix:{sock};
    }}
"""
m = list(re.finditer(r'\n(\s*)location\s+/\s*\{', src))
if not m:
    sys.exit('не нашёл location / в конфиге — добавьте блок вручную')
i = m[-1].start()
open(path, 'w', encoding='utf-8').write(src[:i] + '\n' + block + src[i:])
print('ok')
PY
    fi
    ok "location $XPATH добавлен"
  fi

  grep -qE 'http2|listen.*http2' "$cf" || warn "в конфиге не видно http2 — режим stream-up без него не поднимется"
  grep -q 'proxy_protocol' "$cf" || warn "в конфиге не видно proxy_protocol — проверьте, что REALITY идёт с xver: 1"

  nginx_reload
  step "Проброс /dev/shm"
  patch_compose; recreate_node
  step "Проверка"
  verify_all
  printf '\n  XHTTP path: %s%s%s\n  Добавьте инбаунд XHTTP в Config Profile и Host в панели.\n\n' "$C_BOLD" "$XPATH" "$C_0"
}

verify_all() {
  [[ $DRY_RUN -eq 1 ]] && return 0
  local fail=0

  [[ -S "$NGINX_SOCK" ]] && ok "$NGINX_SOCK на месте" || { err "$NGINX_SOCK отсутствует"; fail=1; }

  if [[ -S "$XRAY_SOCK" ]]; then
    local perm; perm="$(stat -c '%a' "$XRAY_SOCK")"
    [[ "$perm" == "666" ]] && ok "$XRAY_SOCK, права 0666" \
      || { warn "$XRAY_SOCK, права $perm — нужно 0666, добавьте ,0666 в listen инбаунда"; fail=1; }
  else
    info "$XRAY_SOCK ещё нет — появится после сохранения профиля с инбаундом XHTTP"
  fi

  local code
  code="$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "https://$DOMAIN/" || echo 000)"
  [[ "$code" == "200" ]] && ok "заглушка отдаётся (HTTP $code)" || { warn "заглушка вернула HTTP $code"; fail=1; }

  local srv; srv="$(curl -skI --max-time 10 "https://$DOMAIN/" 2>/dev/null | grep -i '^server:' | tr -d '\r' || true)"
  grep -qi cloudflare <<<"$srv" && { err "отвечает Cloudflare, а не nginx — выключите Proxied"; fail=1; }

  if [[ -S "$XRAY_SOCK" && -n "$XPATH" ]]; then
    code="$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "https://$DOMAIN$XPATH" || echo 000)"
    case "$code" in
      400|404) ok "XHTTP отвечает (HTTP $code)" ;;
      502) err "XHTTP: 502 — nginx не достучался до сокета"; fail=1 ;;
      200) err "XHTTP: 200 — отдаётся заглушка, пути не совпали"; fail=1 ;;
      *)   warn "XHTTP: HTTP $code" ;;
    esac
  fi

  (( fail == 0 )) && ok "все проверки пройдены" || warn "часть проверок не прошла, смотрите выше"
  return 0
}

cmd_status() {
  need_root
  [[ -n "$DOMAIN" ]] || {
    local f; f="$(ls -1 "$STATE_DIR"/*.env 2>/dev/null | head -1 || true)"
    [[ -n "$f" ]] && DOMAIN="$(grep -oP '^DOMAIN=\K.*' "$f")" || die "Укажите домен: -d ДОМЕН"
  }
  [[ -f "$STATE_DIR/$DOMAIN.env" ]] && . "$STATE_DIR/$DOMAIN.env"
  step "Состояние $DOMAIN"
  systemctl is-active --quiet nginx && ok "nginx работает" || err "nginx не запущен"
  docker ps --format '{{.Names}}' | grep -qx remnanode && ok "remnanode работает" || err "remnanode не запущен"
  if [[ -f "/etc/letsencrypt/live/$DOMAIN/cert.pem" ]]; then
    local until days
    until="$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$DOMAIN/cert.pem" | cut -d= -f2)"
    days=$(( ( $(date -d "$until" +%s) - $(date +%s) ) / 86400 ))
    (( days > 14 )) && ok "сертификат действует ещё $days дн." || warn "сертификат истекает через $days дн."
  else
    err "сертификата нет"
  fi
  verify_all
}

cmd_uninstall() {
  need_root
  [[ -n "$DOMAIN" ]] || die "Укажите домен: -d ДОМЕН"
  warn "Будут удалены: конфиг nginx для $DOMAIN, заглушка, hook."
  warn "Нода, сертификаты и docker-compose не трогаются."
  confirm "Продолжить?" || die "Прервано."
  run rm -f "$(conf_path)" "/etc/nginx/sites-enabled/$(basename "$(conf_path)")"
  run rm -f /etc/letsencrypt/renewal-hooks/deploy/rw-node-reload.sh
  run rm -rf "$WWW_ROOT"
  run rm -f "$STATE_DIR/$DOMAIN.env"
  nginx_reload || true
  ok "удалено"
}

# ---------------------------------------------------------------- запуск

case "$MODE" in
  install)    cmd_install ;;
  add-xhttp)  cmd_add_xhttp ;;
  status)     cmd_status ;;
  uninstall)  cmd_uninstall ;;
esac
