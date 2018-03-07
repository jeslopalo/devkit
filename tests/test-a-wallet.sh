#!/usr/bin/env bash

source ./create-wallet-entry.lib.sh

wait_for_async_operation() {
    sleep 2
}

expense_params='{ "userId" : 782, "clientId" : 758, "requestId" : 3, "publicId" : "Z182Z" }'
refund_params='{ "userId" : 782, "clientId" : 758 }'
adjustment_params='{ "invoiceId" : 12 }'
income_params='{ "userId" : 782, "clientId" : 758, "paymentDetailId" : 282 }'
withdrawal_params='{ "userId" : 782, "clientId" : 758, "paymentDetailId" : 282 }'


if [ "$#" = 0 ]; then
    printf "\\nCreando wallet\\n"
    wallet=$(./create-wallet.sh "raw")
    printf "$bold%s$normal\\n\\n" "$wallet"
    wallet_id=$(echo ${wallet} | jq .walletId)
else
    wallet_id="${1}"
    printf "\\nReutilizando el wallet %s\\n" "$wallet_id"
fi
./get-wallet.sh ${wallet_id}

printf "\\nCreando una entrada\\n"
entry=$(create_entry_raw "INCOME" "$wallet_id" 80000 "${income_params}")
printf "$bold%s$normal\\n\\n" "$entry"
entry_id=$(echo ${entry} | jq .entryId)
./get-wallet-entry.sh ${wallet_id} ${entry_id}
printf "\\nConfirmando entrada ${entry_id}\\n"
./confirm-entry.sh ${wallet_id} ${entry_id}
wait_for_async_operation
./get-wallet-entry.sh ${wallet_id} ${entry_id}

printf "\\nCreando una entrada para ser cancelada (mas tarde)\\n"
entry=$(create_entry_raw "INCOME" "$wallet_id" 1000)
printf "$bold%s$normal\\n\\n" "$entry"
entry_id=$(echo ${entry} | jq .entryId)
./get-wallet-entry.sh ${wallet_id} ${entry_id}
printf "\\nConfirmando entrada ${entry_id} para ser cancelada\\n"
./confirm-entry.sh ${wallet_id} ${entry_id}
wait_for_async_operation

printf "\\nCreando ingresos\\n"
./create-wallet-income.sh ${wallet_id} -100 "${income_params}"
./create-wallet-income.sh ${wallet_id} 0 "${income_params}"
./create-wallet-income.sh ${wallet_id} 1 "${income_params}"
./create-wallet-income.sh ${wallet_id} 100 "${income_params}"
./create-wallet-income.sh ${wallet_id} 10000 "${income_params}"

printf "\\nCreando gastos\\n"
./create-wallet-expense.sh ${wallet_id} 1000 "${expense_params}"
./create-wallet-expense.sh ${wallet_id} -1000 "${expense_params}"
./create-wallet-expense.sh ${wallet_id} 112 "${expense_params}"
./create-wallet-expense.sh ${wallet_id} 100000 "${expense_params}"

printf "\\nCreando reembolsos\\n"
./create-wallet-refund.sh ${wallet_id} -112 "${refund_params}"
./create-wallet-refund.sh ${wallet_id} 112 "${refund_params}"

printf "\\nCreando ajustes\\n"
./create-wallet-adjustment.sh ${wallet_id} -100 "${adjustment_params}"
./create-wallet-adjustment.sh ${wallet_id} 100 "${adjustment_params}"

printf "\\nCreando reintegros\\n"
./create-wallet-withdrawal.sh ${wallet_id} -1000 "${withdrawal_params}"
./create-wallet-withdrawal.sh ${wallet_id} 1000 "${withdrawal_params}"
./create-wallet-withdrawal.sh ${wallet_id} 100000 "${withdrawal_params}"

printf "\\nCreando una cancelación (no se debe poder)\\n"
./create-wallet-cancel.sh ${wallet_id} +100

printf "\\nCancelando apunte ${entry_id}...\\n"
./get-wallet-entry.sh ${wallet_id} ${entry_id}
./cancel-entry.sh ${wallet_id} ${entry_id}
wait_for_async_operation
./get-wallet-entry.sh ${wallet_id} ${entry_id}

printf "\\nConfigurando el wallet %s\\n" "$wallet_id"
./wallet-set-low-balance-threshold.sh ${wallet_id} 15000
./get-wallet.sh ${wallet_id}
./wallet-delete-low-balance-threshold.sh ${wallet_id}
./get-wallet.sh ${wallet_id}

printf "\\nResultado final\\n"
./get-wallet.sh ${wallet_id}

printf "\\nApuntes por páginas de 3\\n"
./get-wallet-entries.sh ${wallet_id} 0 3
./get-wallet-entries.sh ${wallet_id} 1 3
./get-wallet-entries.sh ${wallet_id} 2 3
./get-wallet-entries.sh ${wallet_id} 3 3

printf "\\nApuntes por páginas de 10\\n"
./get-wallet-entries.sh ${wallet_id} 0 10
./get-wallet-entries.sh ${wallet_id} 1 10

printf "\\nApuntes por páginas de 10 con filtrado\\n"
./get-wallet-entries.sh ${wallet_id} 0 10 \
    "types=INCOME&minAmount=8000&maxAmount=80001&dateFrom=2017-10-02T07:35:14.445Z&dateTo=2027-10-02T07:35:14.445Z"

printf "\\nProbando el borrado de monederos\\n"
printf "\\n\\tCreando wallet para ser borrado (sin apuntes)\\n"
wallet_a_borrar=$(./create-wallet.sh "raw")
printf "\\t$bold%s$normal\\n\\n" "$wallet_a_borrar"
wallet_id_a_borrar=$(echo ${wallet_a_borrar} | jq .walletId)
./delete-wallet.sh "$wallet_id_a_borrar"
./get-wallet.sh "$wallet_id_a_borrar"
printf "\\n\\t--> No debe existir\\n"

printf "\\n\\tCreando wallet para ser borrado (con apunte no confirmado)\\n"
wallet_a_borrar=$(./create-wallet.sh "raw")
printf "\\t$bold%s$normal\\n\\n" "$wallet_a_borrar"
wallet_id_a_borrar=$(echo ${wallet_a_borrar} | jq .walletId)
./create-wallet-income.sh ${wallet_id_a_borrar} 10000 "${income_params}"
./delete-wallet.sh "$wallet_id_a_borrar"
./get-wallet.sh "$wallet_id_a_borrar"
printf "\\n\\t--> Si debe existir\\n"

printf "\\n\\tCreando wallet para ser borrado (con apunte confirmado)\\n"
wallet_a_borrar=$(./create-wallet.sh "raw")
printf "\\t$bold%s$normal\\n\\n" "$wallet_a_borrar"
wallet_id_a_borrar=$(echo ${wallet_a_borrar} | jq .walletId)
entry=$(create_entry_raw "INCOME" "$wallet_id_a_borrar" 80000 "${income_params}")
entry_id=$(echo ${entry} | jq .entryId)
./confirm-entry.sh ${wallet_id_a_borrar} ${entry_id}
wait_for_async_operation
./delete-wallet.sh "$wallet_id_a_borrar"
./get-wallet.sh "$wallet_id_a_borrar"
printf "\\n\\t--> Si debe existir\\n"
