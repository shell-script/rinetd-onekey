##################################################
# Anything wrong? Find me via telegram: @CN_SZTL #
##################################################

#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function set_fonts_colors(){
# Font colors
default_fontcolor="\033[0m"
red_fontcolor="\033[31m"
green_fontcolor="\033[32m"
# Background colors
green_backgroundcolor="\033[42;37m"
# Fonts
error_font="${red_fontcolor}[Error]${default_fontcolor}"
ok_font="${green_fontcolor}[OK]${default_fontcolor}"
}

function check_os(){
	clear
	echo -e "正在检测当前是否为ROOT用户..."
	if [[ $EUID -ne 0 ]]; then
		clear
		echo -e "${error_font}当前并非ROOT用户，请先切换到ROOT用户后再使用本脚本。"
		exit 1
	else
		clear
		echo -e "${ok_font}检测到当前为Root用户。"
	fi
	clear
	echo -e "正在检测此OS是否被支持..."
	if [ ! -z "$(cat /etc/issue | grep Debian)" ];then
		clear
		echo -e "${ok_font}该脚本支持您的系统。"
	elif [ ! -z "$(cat /etc/issue | grep Ubuntu)" ];then
		clear
		echo -e "${ok_font}该脚本支持您的系统。"
	else
		clear
		echo -e "${error_font}目前暂不支持您使用的操作系统，请切换至Debian/Ubuntu。"
		exit 1
	fi
	if [[ $(uname -m) = "x86_64" ]];then
		clear
		echo -e "${ok_font}该脚本支持您的系统版本。"
	else
		clear
		echo -e "${error_font}目前暂不支持您使用的操作系统，请切换至Debian/Ubuntu x86_64。"
	fi
}

function check_install_status(){
	install_type=$(cat /usr/local/rinetd/install_type.txt)
	if [[ ${install_type} = "" ]]; then
		install_status="${red_fontcolor}未安装${default_fontcolor}"
	else
		install_status="${green_fontcolor}已安装${default_fontcolor}"
	fi
	rinetd_pid=$(ps -ef |grep "rinetd" |grep -v "grep" | grep -v ".sh"| grep -v "init.d" |grep -v "service" |awk '{print $2}')
	if [[ ${rinetd_pid} = "" ]]; then
		rinetd_config=$(cat /usr/local/rinetd/config.json)
		if [[ ${rinetd_config} = "" ]]; then
			rinetd_status="${red_fontcolor}未安装${default_fontcolor}"
		else
			rinetd_status="${red_fontcolor}未运行${default_fontcolor}"
		fi
	else
		rinetd_status="${green_fontcolor}正在运行${default_fontcolor} | ${green_fontcolor}${rinetd_pid}${default_fontcolor}"
	fi
}

function echo_install_list(){
	clear
	echo -e "脚本当前安装状态：${install_status}
--------------------------------------------------------------------------------------------------
安装Rinetd:
	1.Rinetd+PCC
	2.Rinetd+BBR
	3.Rinetd+BBR(魔改版)
--------------------------------------------------------------------------------------------------
Rinetd当前运行状态：${rinetd_status}
	4.添加加速端口
	5.删除加速端口
	6.更新脚本
	7.更新程序
	8.卸载程序

	9.启动程序
	10.关闭程序
	11.重启程序
--------------------------------------------------------------------------------------------------"
	stty erase '^H' && read -p "请输入序号：" determine_type
	if [[ ${determine_type} = "" ]]; then
		clear
		echo -e "${error_font}请输入序号！"
		exit 1
	elif [[ ${determine_type} -lt 0 ]]; then
		clear
		echo -e "${error_font}请输入正确的序号！"
		exit 1
	elif [[ ${determine_type} -gt 11 ]]; then
		clear
		echo -e "${error_font}请输入正确的序号！"
		exit 1
	else
		data_processing
	fi
}

function data_processing(){
	clear
	echo -e "正在处理请求中..."
	if [[ ${determine_type} = "4" ]]; then
		prevent_uninstall_check
		add_speededup_port
	elif [[ ${determine_type} = "5" ]]; then
		prevent_uninstall_check
		del_speededup_port
	elif [[ ${determine_type} = "6" ]]; then
		upgrade_shell_script
	elif [[ ${determine_type} = "7" ]]; then
		prevent_uninstall_check
		upgrade_program
		restart_service
	elif [[ ${determine_type} = "8" ]]; then
		prevent_uninstall_check
		uninstall_program
	elif [[ ${determine_type} = "9" ]]; then
		prevent_uninstall_check
		start_service
	elif [[ ${determine_type} = "10" ]]; then
		prevent_uninstall_check
		stop_service
	elif [[ ${determine_type} = "11" ]]; then
		prevent_uninstall_check
		restart_service
	else
		clear
		echo -e "正在安装中..."
		prevent_install_check
		os_update
		mkdir /usr/local/rinetd
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}建立Rinetd文件夹成功。"
		else
			clear
			echo -e "${error_font}建立Rinetd文件夹失败！"
			clear_install
			exit 1
		fi
		if [[ ${determine_type} = "1" ]]; then
			rinetd_ver=$(wget -qO- "https://github.com/linhua55/lkl_study/tags"|grep "/linhua55/lkl_study/releases/tag/"|head -n 1|awk -F "/tag/" '{print $2}'|sed 's/\">//')
			if [[ ${rinetd_ver} = "" ]]; then
				echo -e "${error_font}获取Rinetd版本号失败！"
				exit 1
			fi
			wget "https://github.com/linhua55/lkl_study/releases/download/${rinetd_ver}/rinetd_pcc" -O "/usr/local/rinetd/rinetd"
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}下载Rinetd文件成功。"
			else
				clear
				echo -e "${error_font}下载Rinetd文件失败！"
				exit
			fi
			chmod -x /usr/local/rinetd/rinetd
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}设置Rinetd权限成功。"
			else
				clear
				echo -e "${error_font}设置Rinetd权限失败！"
				exit 1
			fi
			echo -e "1" > /usr/local/rinetd/install_type.txt
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}写出安装信息成功。"
			else
				clear
				echo -e "${error_font}写出安装信息失败！"
				exit 1
			fi
		elif [[ ${determine_type} = "2" ]]; then
			rinetd_ver=$(wget -qO- "https://github.com/linhua55/lkl_study/tags"|grep "/linhua55/lkl_study/releases/tag/"|head -n 1|awk -F "/tag/" '{print $2}'|sed 's/\">//')
			if [[ ${rinetd_ver} = "" ]]; then
				echo -e "${error_font}获取Rinetd版本号失败！"
				exit 1
			fi
			wget "https://github.com/linhua55/lkl_study/releases/download/${rinetd_ver}/rinetd_bbr" -O "/usr/local/rinetd/rinetd"
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}下载Rinetd文件成功。"
			else
				clear
				echo -e "${error_font}下载Rinetd文件失败！"
				exit
			fi
			chmod -x /usr/local/rinetd/rinetd
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}设置Rinetd权限成功。"
			else
				clear
				echo -e "${error_font}设置Rinetd权限失败！"
				exit 1
			fi
			echo -e "2" > /usr/local/rinetd/install_type.txt
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}写出安装信息成功。"
			else
				clear
				echo -e "${error_font}写出安装信息失败！"
				exit 1
			fi
		elif [[ ${determine_type} = "3" ]]; then
			rinetd_ver=$(wget -qO- "https://github.com/linhua55/lkl_study/tags"|grep "/linhua55/lkl_study/releases/tag/"|head -n 1|awk -F "/tag/" '{print $2}'|sed 's/\">//')
			if [[ ${rinetd_ver} = "" ]]; then
				echo -e "${error_font}获取Rinetd版本号失败！"
				exit 1
			fi
			wget "https://github.com/linhua55/lkl_study/releases/download/${rinetd_ver}/rinetd_bbr_powered" -O "/usr/local/rinetd/rinetd"
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}下载Rinetd文件成功。"
			else
				clear
				echo -e "${error_font}下载Rinetd文件失败！"
				exit
			fi
			chmod -x /usr/local/rinetd/rinetd
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}设置Rinetd权限成功。"
			else
				clear
				echo -e "${error_font}设置Rinetd权限失败！"
				exit 1
			fi
			echo -e "3" > /usr/local/rinetd/install_type.txt
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}写出安装信息成功。"
			else
				clear
				echo -e "${error_font}写出安装信息失败！"
				exit 1
			fi
		fi
		clear
		set_speededup_port
		clear
		set_rinetd_system_config
		clear
		restart_service
		clear
		echo -e "${ok_font}Rinetd安装成功。"
	fi
	echo -e "\n${ok_font}请求处理完毕。"
}


function upgrade_shell_script(){
	clear
	echo -e "正在更新脚本中..."
	filepath=$(cd "$(dirname "$0")"; pwd)
	filename=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
	curl -O https://raw.githubusercontent.com/1715173329/rinetd-onekey/master/rinetd-go.sh
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}脚本更新成功，脚本位置：\"${green_backgroundcolor}${filename}/rinetd-go.sh${default_fontcolor}\"，使用：\"${green_backgroundcolor}bash ${filename}/rinetd-go.sh${default_fontcolor}\"。"
	else
		clear
		echo -e "${error_font}脚本更新失败！"
	fi
}

function prevent_uninstall_check(){
	clear
	echo -e "正在检查安装状态中..."
	install_type=$(cat /usr/local/rinetd/install_type.txt)
	if [ "${install_type}" = "" ]; then
		clear
		echo -e "${error_font}您未安装本程序。"
		exit 1
	else
		echo -e "${ok_font}您已安装本程序，正在执行相关命令中..."
	fi
}

function start_service(){
	clear
	echo -e "正在启动服务中..."
	if [[ ${rinetd_pid} -eq 0 ]]; then
		service rinetd start
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}Rinetd 启动成功。"
		else
			clear
			echo -e "${error_font}Rinetd 启动失败！"
			exit 1
		fi
	else
		clear
		echo -e "${error_font}Rinetd 正在运行。"
		exit 1
	fi
}

function stop_service(){
	clear
	echo -e "正在停止服务中..."
	if [[ ${rinetd_pid} -eq 0 ]]; then
		clear
		echo -e "${error_font}Rinetd 未在运行。"
	else
		service rinetd stop
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}Rinetd 停止成功。"
		else
			clear
			echo -e "${error_font}Rinetd 停止失败！"
			exit 1
		fi
	fi
}

function restart_service(){
	clear
	echo -e "正在重启服务中..."
	service rinetd restart
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}Rinetd 重启成功。"
	else
		clear
		echo -e "${error_font}Rinetd 重启失败！"
		exit 1
	fi
}

function prevent_install_check(){
	clear
	echo -e "正在检测安装状态中..."
		if [[ ${install_status} = "${green_fontcolor}已安装${default_fontcolor}" ]]; then
			echo -e "${error_font}您已经安装过了，请勿再次安装，若您需要切换至其他模式，请先卸载后再使用安装功能。"
			exit 1
		elif [[ ${rinetd_status} = "${red_fontcolor}未安装${default_fontcolor}" ]]; then
			echo -e "${ok_font}检测完毕，符合要求，正在执行命令中..."
		else
			echo -e "${error_font}您的VPS上已经安装Rinetd，请勿再次安装，若您需要使用本脚本，请先卸载后再使用安装功能。"
			exit 1
		fi
}

function uninstall_program(){
	clear
	echo -e "正在卸载中..."
	service rinetd stop
	systemctl disable rinetd.service
	update-rc.d -f rinetd remove
	rm -rf /etc/systemd/system/rinetd.service
	rm -rf /usr/local/rinetd
	if [[ $? -ne 0 ]];then
		clear
		echo -e "${error_font}Rinetd卸载失败！"
		exit 1
	else
		clear
		echo -e "${ok_font}Rinetd卸载成功。"
	fi
}

function upgrade_program(){
	clear
	echo -e "正在升级中..."
	rinetd_ver=$(wget -qO- "https://github.com/linhua55/lkl_study/tags"|grep "/linhua55/lkl_study/releases/tag/"|head -n 1|awk -F "/tag/" '{print $2}'|sed 's/\">//')
	if [[ ${rinetd_ver} = "" ]]; then
		echo -e "${error_font}获取Rinetd版本号失败！"
		exit 1
	fi
	mv /usr/local/rinetd/rinetd /usr/local/rinetd/rinetd.bak
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}备份旧Rinetd文件成功。"
	else
		clear
		echo -e "${error_font}备份旧Rinetd文件失败！"
		exit 1
	fi
	install_type=$(cat /usr/local/rinetd/install_type.txt)
	if [[ ${install_type} = "1" ]]; then
		wget "https://github.com/linhua55/lkl_study/releases/download/${rinetd_ver}/rinetd_pcc" -O "/usr/local/rinetd/rinetd"
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}下载Rinetd文件成功。"
		else
			clear
			echo -e "${error_font}下载Rinetd文件失败！"
			mv /usr/local/rinetd/rinetd.bak /usr/local/rinetd/rinetd
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}恢复旧Rinetd文件成功。"
			else
				clear
				echo -e "${error_font}恢复旧Rinetd文件失败！"
				exit 1
			fi
			exit 1
		fi
		chmod -x /usr/local/rinetd/rinetd
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}设置Rinetd权限成功。"
		else
			clear
			echo -e "${error_font}设置Rinetd权限失败！"
			exit 1
		fi
	elif [[ ${install_type} = "2" ]]; then
		wget "https://github.com/linhua55/lkl_study/releases/download/${rinetd_ver}/rinetd_bbr" -O "/usr/local/rinetd/rinetd"
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}下载Rinetd文件成功。"
		else
			clear
			echo -e "${error_font}下载Rinetd文件失败！"
			mv /usr/local/rinetd/rinetd.bak /usr/local/rinetd/rinetd
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}恢复旧Rinetd文件成功。"
			else
				clear
				echo -e "${error_font}恢复旧Rinetd文件失败！"
				exit 1
			fi
			exit 1
		fi
		chmod -x /usr/local/rinetd/rinetd
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}设置Rinetd权限成功。"
		else
			clear
			echo -e "${error_font}设置Rinetd权限失败！"
			exit 1
		fi
	elif [[ ${install_type} = "3" ]]; then
		wget "https://github.com/linhua55/lkl_study/releases/download/${rinetd_ver}/rinetd_bbr_powered" -O "/usr/local/rinetd/rinetd"
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}下载Rinetd文件成功。"
		else
			clear
			echo -e "${error_font}下载Rinetd文件失败！"
			mv /usr/local/rinetd/rinetd.bak /usr/local/rinetd/rinetd
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}恢复旧Rinetd文件成功。"
			else
				clear
				echo -e "${error_font}恢复旧Rinetd文件失败！"
				exit 1
			fi
			exit 1
		fi
		chmod -x /usr/local/rinetd/rinetd
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}设置Rinetd权限成功。"
		else
			clear
			echo -e "${error_font}设置Rinetd权限失败！"
			exit 1
		fi
	fi
	clear
	restart_service
	clear
	echo -e "${ok_font}Rinetd升级成功。"
}

function clear_install(){
	clear
	echo -e "正在卸载中..."
	service rinetd stop
	systemctl disable rinetd.service
	update-rc.d -f rinetd remove
	rm -rf /etc/systemd/system/rinetd.service
	rm -rf /usr/local/rinetd
	if [[ $? -ne 0 ]];then
		clear
		echo -e "${error_font}Rinetd卸载失败！"
		exit 1
	else
		clear
		echo -e "${ok_font}Rinetd卸载成功。"
	fi
}

function os_update(){
	clear
	echo -e "正在安装/更新系统组件中..."
	clear
	apt-get -y update
	apt-get -y upgrade
	apt-get -y install wget curl lsof cron iptables gcc
	if [[ $? -ne 0 ]];then
		clear
		echo -e "${error_font}系统组件更新失败！"
		exit 1
	else
		clear
		echo -e "${ok_font}系统组件更新成功。"
	fi
}


function set_speededup_port(){
	clear
	echo -e "正在配置Rinetd加速端口中..."
	clear
	stty erase '^H' && read -p "请输入欲加速的本地端口：" speededup_local_port
	if [[ ${speededup_local_port} = "" ]]; then
		echo -e "$(error_font)请输入端口！"
		clear_install
		exit 1
	else
		if [[ ${speededup_local_port} -lt 1 ]]; then
			echo -e "$(error_font)请输入正确的端口！"
			clear_install
			exit 1
		elif [[ ${speededup_local_port} -gt 65535 ]]; then
			echo -e "$(error_font)请输入正确的端口！"
			clear_install
			exit 1
		fi
	fi
	stty erase '^H' && read -p "请输入欲加速的远程连接端口(默认：${speededup_local_port}，非NAT或Docker通常可直接回车)：" speededup_connectport_port
	if [[ ${speededup_connectport_port} = "" ]]; then
		speededup_connectport_port=${speededup_local_port}
	fi
	if [[ ${speededup_connectport_port} -lt 1 ]]; then
		echo -e "$(error_font)请输入正确的端口！"
		clear_install
		exit 1
	elif [[ ${speededup_connectport_port} -gt 65535 ]]; then
		echo -e "$(error_font)请输入正确的端口！"
		clear_install
		exit 1
	fi
	echo -e "0.0.0.0 ${speededup_local_port} 0.0.0.0 ${speededup_connectport_port}" > /usr/local/rinetd/config.json
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}Rinetd端口配置成功。"
	else
		clear
		echo -e "${error_font}Rinetd端口配置失败！"
		clear_install
		exit 1
	fi
}


function set_rinetd_system_config(){
	clear
	echo -e "正在配置Rinetd中..."
	clear
	cat <<-EOF > /etc/systemd/system/rinetd.service
		[Unit]
		Description=rinetd

		[Service]
		ExecStart=/usr/local/rinetd/rinetd -f -c /usr/local/rinetd/config.json raw venet0:0
		Restart=always

		[Install]
		WantedBy=multi-user.target
	EOF
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}配置Rinetd成功。"
	else
		clear
		echo -e "${error_font}配置Rinetd失败！"
		clear_install
		exit 1
	fi
	chmod -x /etc/systemd/system/rinetd.service
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}设置Rinetd服务文件权限成功。"
	else
		clear
		echo -e "${error_font}设置Rinetd服务文件权限失败！"
		exit 1
	fi
	systemctl enable rinetd.service
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}配置Rinetd成功。"
	else
		clear
		echo -e "${error_font}配置Rinetd失败！"
		clear_install
		exit 1
	fi
}


function add_speededup_port(){
	clear
	echo -e "正在配置Rinetd加速端口中..."
	clear
	stty erase '^H' && read -p "请输入欲加速的本地端口：" speededup_local_port
	if [[ ${speededup_local_port} = "" ]]; then
		echo -e "{ok_font}取消设置加速端口成功，如需设置新的加速端口，请再次运行本脚本并输入4"
		exit 1
	else
		if [[ ${speededup_local_port} -lt 1 ]]; then
			echo -e "$(error_font)请输入正确的端口！"
			exit 1
		elif [[ ${speededup_local_port} -gt 65535 ]]; then
			echo -e "$(error_font)请输入正确的端口！"
			exit 1
		fi
	fi
	stty erase '^H' && read -p "请输入欲加速的远程连接端口(默认：${speededup_local_port}，非NAT或Docker通常可直接回车)：" speededup_connectport_port
	if [[ ${speededup_connectport_port} = "" ]]; then
		speededup_connectport_port=${speededup_local_port}
	fi
	if [[ ${speededup_connectport_port} -lt 1 ]]; then
		echo -e "$(error_font)请输入正确的端口！"
		exit 1
	elif [[ ${speededup_connectport_port} -gt 65535 ]]; then
		echo -e "$(error_font)请输入正确的端口！"
		exit 1
	fi
	echo -e "0.0.0.0 ${speededup_local_port} 0.0.0.0 ${speededup_connectport_port}" >> /usr/local/rinetd/config.json
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}Rinetd端口配置成功。"
	else
		clear
		echo -e "${error_font}Rinetd端口配置失败！"
		exit 1
	fi
	clear
	restart_service
}

function del_speededup_port(){
	clear
	echo -e "正在配置Rinetd加速端口中..."
	clear
	stty erase '^H' && read -p "请输入欲取消加速的本地端口：" del_speededup_local_port
	if [[ ${del_speededup_local_port} = "" ]]; then
		echo -e "{error_font}请输入欲取消加速的本地端口！"
		exit 1
	else
		if [[ ${del_speededup_local_port} -lt 1 ]]; then
			echo -e "$(error_font)请输入正确的端口！"
			exit 1
		elif [[ ${del_speededup_local_port} -gt 65535 ]]; then
			echo -e "$(error_font)请输入正确的端口！"
			exit 1
		fi
	fi
	sed -i "/0.0.0.0 ${del_speededup_local_port}/d" /usr/local/rinetd/config.json
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}Rinetd端口配置成功。"
	else
		clear
		echo -e "${error_font}Rinetd端口配置失败！"
		exit 1
	fi
	sed -i /^[[:space:]]*$/d /usr/local/rinetd/config.json
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}Rinetd端口配置成功。"
	else
		clear
		echo -e "${error_font}Rinetd端口配置失败！"
		exit 1
	fi
	clear
	restart_service
}


function main(){
	set_fonts_colors
	check_os
	check_install_status
	echo_install_list
}

	main
