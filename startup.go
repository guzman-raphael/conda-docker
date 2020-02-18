package main

import (
	"strings"
	"io/ioutil"
	"os"
	"strconv"
	"os/exec"
	"syscall"
)
// import . "fmt"

func main() {
	var user, uid, gid string = os.Getenv("PYTHON_USER"), os.Args[1], os.Args[2]
	var home string = "/home/" + user

	pass_byte, _ := ioutil.ReadFile("/etc/passwd")
	pass_str := string(pass_byte)
	pass_str = strings.Replace(
		pass_str, user + ":x:3000:anaconda", user + ":x:" + uid + ":" + gid, -1)
	pass_file, _ := os.Create("/etc/passwd")
	pass_file.WriteString(pass_str)
	pass_file.Close()

	// group_byte, _ := ioutil.ReadFile("/etc/group")
	// group_str := string(group_byte)
	// group_str = strings.Replace(
	// 	group_str, user + ":x:3000", user + ":x:" + uid, -1)
	// group_file, _ := os.Create("/etc/group")
	// group_file.WriteString(group_str)
	// group_file.Close()

	uid_int, _ := strconv.Atoi(uid)
	gid_int, _ := strconv.Atoi(gid)
	os.Chown(home, uid_int, gid_int)
	os.Chown(home + "/.local", uid_int, gid_int)
	os.Chown(home + "/.local/bin", uid_int, gid_int)
	os.Chown(home + "/.cache", uid_int, gid_int)
	os.Chown(home + "/.cache/pip", uid_int, gid_int)
	os.Chown(home + "/.cache/pip/wheels", uid_int, gid_int)
	os.Chown(home + "/.cache/pip/wheels", uid_int, gid_int)
	os.Chown(home + "/.conda", uid_int, gid_int)
	os.Chown(home + "/.conda/environments.txt", uid_int, gid_int)
	os.Chown(home + "/.condarc", uid_int, gid_int)
	// os.Chown(home + "/.miniconda3", uid_int, gid_int)
	// os.Chown(home + "/.miniconda3/pkg", uid_int, gid_int)
	// os.Chown(home + "/.miniconda3/envs", uid_int, gid_int)
	// exec.Command("apk add $(paste -s -d ' ' ${APK_REQUIREMENTS} 2> /dev/null || echo \"\")").Output()
	// cmd, err := exec.Command("whoami").Output()

	// cmd := exec.Command("id", "-u")
	// var output1 string = "raphael"
	// if _, err := os.Stat(os.Getenv("APK_REQUIREMENTS")); err == nil {
	// 	cmd1 := exec.Command("cat", "/apk_requirements.txt")
	// 	cmd1.SysProcAttr = &syscall.SysProcAttr{}
	// 	cmd1.SysProcAttr.Credential = &syscall.Credential{Uid: 0, Gid: 0}
	// 	output1, err1 := cmd1.Output()

	// 	if err1 != nil {
	// 		println(err1.Error())
	// 		return
	// 	}
	// 	println("output: " + string(output1))
	// }
	// println("output: " + string(output1))


	// paste -s -d ' ' ${APK_REQUIREMENTS} 2> /dev/null || echo ""
	// cmd1 := exec.Command("paste", "-s", "-d", "' '", os.Getenv("APK_REQUIREMENTS"), "2>", "/dev/null", "||", "echo",  "''")
	// output1, err1 := cmd1.Output()
	// if err1 != nil {
	// 	println(err1.Error())
	// 	return
	// }
	if _, err := os.Stat(os.Getenv("APK_REQUIREMENTS")); err == nil {
		cmd1 := exec.Command("paste", "-s", "-d", ",", os.Getenv("APK_REQUIREMENTS"))
		output1, err1 := cmd1.Output()
		if err1 != nil {
			println(err1.Error())
			return
		}
		args := []string{"add"}
		pkgs := strings.Split(string(output1), ",")
		args = append(args,pkgs...)
		cmd2 := exec.Command("apk", args...)
		cmd2.SysProcAttr = &syscall.SysProcAttr{}
		cmd2.SysProcAttr.Credential = &syscall.Credential{Uid: 0, Gid: 0}
		_, err2 := cmd2.Output()
		if err2 != nil {
			println(err2.Error())
			return
		}
	}


	

	// if err2 != nil {
	// 		log.Fatal(err2)
	// }

	// // output has trailing \n
	// // need to remove the \n
	// // otherwise it will cause error for strconv.Atoi
	// // log.Println(output[:len(output)-1])

	// // 0 = root, 501 = non-root user
	// i, err := strconv.Atoi(string(output2[:len(output2)-1]))

	// if err != nil {
	// 		log.Fatal(err)
	// }

	// if i == 0 {
	// 		log.Println("Awesome! You are now running this program with root permissions!")
	// } else {
	// 		log.Fatal("This program must be run as root! (sudo)")
	// }


	// apk add $(paste -s -d ' ' ${APK_REQUIREMENTS} 2> /dev/null || echo "")
	// os.Chown(home + "/.conda", uid_int, gid_int)
	// os.Chown(home + "/.conda/envs", uid_int, gid_int)
	// os.Chown(home + "/.conda/envs/dj", uid_int, gid_int)
}
