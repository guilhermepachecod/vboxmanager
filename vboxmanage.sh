#!/bin/bash

# Mostra o menu
echo "Escolha uma opção:"
echo "1 - Listar todas as VMs"
echo "2 - Listar um VMs com detalhes"
echo "3 - Listar apenas as VMs em execução"
echo "4 - Iniciar uma VM pelo nome ou ID"
echo "5 - Enviar Sinal de desligamento pelo nome ou ID"
echo "6 - Editar a VM"
echo "7 - Clonar a VM"
echo "8 - Criar VM"
echo "9 - Remove VM"
echo "0 - Update"

# Lê a opção selecionada
read -p "Opção: " opcao

# Executa o comando correspondente à opção selecionada
case $opcao in
1)
  vboxmanage list vms
  ;;
2)
  echo "Digite o nome ou ID da VM: "
  read -p "Nome ou ID: " nome_ou_id
  vboxmanage showvminfo "$nome_ou_id"
  ;;
3)
  vboxmanage list runningvms
  ;;
4)
  echo "Digite o nome ou ID da VM: "
  read -p "Nome ou ID: " nome_ou_id
  VBoxManage startvm "$nome_ou_id" --type headless
  ;;
5)
  echo "Digite o nome ou ID da VM: "
  read -p "Nome ou ID: " nome_ou_id
  vboxmanage controlvm "$nome_ou_id" poweroff --type acpipowerbutton
  ;;  
6)
  echo "Digite o nome ou ID da VM: "
  read -p "Nome ou ID: " nome_ou_id
  echo "Escolha uma opção:"
  echo "1 - Alterar CPU"
  echo "2 - Alterar Rede"
  echo "3 - Auto-Iniciar"
  echo "4 - Ativar VRDE"
  echo "5 - Adicionar DVD"
  read -p "Opção: " editopcao
  case $editopcao in
  1)
    vboxmanage showvminfo "$nome_ou_id" | grep cpu
    echo "Digite o numero de cpus"
    read -p "CPUs: " cpu
    vboxmanage modifyvm "$nome_ou_id" --cpus $cpu
    ;;
  2)
    vboxmanage showvminfo "$nome_ou_id" | grep NIC
    echo "Digite para escolhar o adapter(eno1, enp2s1, wlp2s2)"
    read -p "Adapter: " adapt
    read -p "num NIC : " nic
    vboxmanage modifyvm "$nome_ou_id" --nic1 bridged --bridgeadapter1 "$adapt"
    ;;
  3)
    vboxmanage showvminfo "$nome_ou_id" | grep autostart
    read -p "autostart(on : off) : " autostart
    vboxmanage modifyvm "$nome_ou_id" --autostart-enabled $autostart
    ;;
  4)
    vboxmanage showvminfo "$nome_ou_id" | grep vrde
    read -p "vrde(on : off) : " vrde
    VBoxManage modifyvm "$nome_ou_id" --vrde $vrde
    ;;
  5)
  vboxmanage storagectl $nome_ou_id --name DVD --add sata --bootable on
  vboxmanage storageattach $nome_ou_id --storagectl DVD --port 1 --device 0 --type dvddrive --medium $HOME/files/Programas/SO/Linux/debian/debian-12.0.0-amd64-netinst.iso
  ;;
  *)
    echo "Opção inválida"
    exit
    ;;
  esac
  ;; 
7)
  echo "Digite o nome ou ID da VM: "
  read -p "Nome ou ID: " nome_ou_id
  vboxmanage clonevm "$nome_ou_id" --mode=machine 
  ;;
8)
  echo "Digite o nome da VM: "
  read -p "Nome: " nome_ou_id
  vboxmanage list ostypes | grep ID:
  echo "Digite ID do ostype: (Windows10_64 Linux26_64 Debian12_64)"
  read -p "ostype: " ostype
  echo "Memoria 2048 = 2gb"
  read -p "osmem: " osmem
  vboxmanage createvm --name "$nome_ou_id" --ostype "$ostype" --register
  vboxmanage modifyvm "$nome_ou_id" --memory $osmem
  echo "Vamos Criar o disco da VM"
  echo "Qual o tamanho do disco?(20480 = 20gb)"
  read -p "Disc size: " discksize
  vboxmanage createmedium disk --filename "$HOME/VirtualBox VMs/$nome_ou_id/$nome_ou_id.vdi" --size $discksize
  vboxmanage storagectl $nome_ou_id --name SATA --add sata --bootable on
  vboxmanage storageattach $nome_ou_id --storagectl SATA --port 0 --device 0 --type hdd --medium $HOME/VirtualBox\ VMs/$nome_ou_id/$nome_ou_id.vdi
  echo "Digite para escolhar o adapter(eno1, enp2s1, wlp2s2)"
  read -p "Adapter: " adapt
  vboxmanage modifyvm "$nome_ou_id" --nic1 bridged --bridgeadapter1 "$adapt"
  echo "Porta do vrde 5901"
  read -p "vrport: " vrport
  vboxmanage modifyvm "$nome_ou_id" --vrde on --vrde-port $vrport
  sudo vboxmanage modifyvm "$nome_ou_id" --autostart-enabled on
  vboxmanage startvm "$nome_ou_id" --type headless
  ;;
9)
  echo "Digite o nome ou ID da VM: "
  read -p "Nome ou ID: " nome_ou_id
  vboxmanage unregistervm "$nome_ou_id" --delete
  ;;
0)
  rm vboxmanage.sh
  wget https://github.com/guilhermepachecod/vboxmanager/vboxmanage.sh
  ;;
*)
  echo "Opção inválida"
  exit
  ;;
esac
