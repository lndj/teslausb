# One-step setup

这是设置 Pi 的简化过程。 您将烧录 Raspbian Buster Lite 的预配置版本，然后填写配置文件。

## Notes

* 假设您的 Pi 可以访问 Wifi，并可以访问互联网（在设置期间）。 （但目前所有设置方法都可以。） USB 网络仍可用于故障排除或手动设置
* 本镜像适用于 “自动化”（已测试）或 “手动”（较少测试）设置。
* 当前未在使用自动化设置时使用 rsync/rclone 方法进行测试，但是您可以在配置文件中指定“none”作为存档方法，这会将 pi 配置为 wifi 可访问的 USB 驱动器，因此您可以配置 rclone/ rsync 并重新运行 setup-teslausb 脚本。

## 首次启动 Pi 之前配置您的 SD 卡

1. 使用 Etcher 或者其他类似的软件烧录 [最新的镜像](https://github.com/lndj/teslausb/suites/3896567169/artifacts/97164886) 。

2. 再次使用读卡器将 SD 卡插入您的电脑，并在 `boot` 目录下创建名为 `teslausb_setup_variables.conf` 的文件，来导出一些环境变量，用来配置相关的功能（包括归档、WiFi、已经通知功能等）。

在您的 SD 卡的 `boot` 文件夹下，已经有一个名为 `teslausb_setup_variables.conf.sample` 的参考配置，你可以将其重命名为 `teslausb_setup_variables.conf`，并按需修改配置。同时，您也可以通过 Github 在线访问该样例文件 [pi-gen-sources/00-teslausb-tweaks/files/teslausb_setup_variables.conf.sample](https://github.com/lndj/teslausb/blob/main-dev/pi-gen-sources/00-teslausb-tweaks/files/teslausb_setup_variables.conf.sample)。

该样例配置文件包含了配置的说明文档和一些建议的值。

**注意:** 如果您在 Windows 上创建或者编辑该配置文件，请注意保存文件时使用了正确的扩展类型(.conf)。建议在 Windows 中禁用“隐藏已知文件类型的扩展名”选项，以便您可以看到完整的文件名。

    确保根据 [bash 引用规则](https://www.gnu.org/software/bash/manual/bash.html#Quoting) 正确引用和或转义所有值，尤其是您的 WiFi SSID 和密码， 此外，任何`&`、`/` 和`\` 也可以通过在它们前面加上`\` 进行转义。如果密码不包含单引号字符，您可以将整个密码括在单引号中，如下所示：
    ```
    export WIFIPASS='password'
    ```
    即使它包含其他可能对 bash 很特殊的字符，如 \\、* 和 $（但请注意，\\ 仍应使用额外的 \\ 进行转义，以便正确处理密码）

    如果密码确实包含单引号，则需要使用不同的语法。 例如。 如果密码是`pass'word`，你可以使用：
    ```
    export WIFIPASS=$'pass\'word'
    ```

    如果密码同时包含单引号和反斜杠，例如 `pass'wo\rd`你会使用：
    ```
    export WIFIPASS=$'pass\'wo\\rd'
    ```

    同样，如果您的 WiFi SSID 名称中有空格，请确保它们被转义或引用。

    例如，如果您的 SSID 是
    ```
    Foo Bar 2.4 GHz
    ```
    你需要这样配置：
    ```
    export SSID=Foo\ Bar\ 2.4\ GHz
    ```
    或者
    ```
    export SSID='Foo Bar 2.4 GHz'
    ```

3. 启动您的 Pi ，稍等片刻，观察一系列闪烁（2、3、4、5），然后等待重新启动后，使 CAM 和 Music （如果配置了音乐驱动器的话）驱动器在您的 PC/Mac 上可用。 LED 闪光阶段含义如下所示：


| 阶段 (闪烁次数)  |  活动 |
|---|---|
| 2 | 验证所需的配置文件被正确创建 |
| 3 | 下载配置所需的脚本和资源 |
| 4 | 创建分区和相应的文件，用于存储车机视频和音乐内容) |
| 5 | 设置完成；将文件系统挂载为只读类型并重新启动 |

Pi 应当可以使用 `ssh` 来连接 `pi@teslausb.local`，通过 Wifi（如果自动设置工作）或 USB 网络（如果没有）。大概需要 5min 或者更多时间来进行自动配置，时间长短取决于您的网络速度等因素影响。`ssh` 服务的对用户 `pi@teslausb.local` 的默认密码是 `raspberry`。推荐您在首次登陆时修改默认密码。您可以用 `passwd` 命令来修改密码。

如果仅插入电源或您的汽车，请等待几分钟，直到 LED 开始稳定闪烁，这意味着存档循环正在运行，您可以开始使用了。

你应该在 `/boot` 目录下中看到 `TESLAUSB_SETUP_FINISHED` 和 `WIFI_ENABLED` 文件作为自动设置成功的标志。


### 常见问题处理

* 通过 `ssh` 链接到 `pi@teslausb.local` (假设 Wifi 已经链接且处于同一网络下，或者您的 Pi 通过 USB 连接到您的计算机) 然后观察 `/boot/teslausb-headless-setup.log` 文件的内容。

* 使用命令 `sudo -i` 然后执行 `/etc/rc.local`。此脚本可以对于重新启动而不是重新运行之前的步骤具有相当大的弹性，并且会告诉您有关进度/失败的信息。

* 如果 WiFi 没有连接成功：
    * 再次检查配置文件 `teslausb_setup_variables.conf` 中的 SSID 和 WIFIPASS 变量的配置是否正确，然后删除 `/boot/WIFI_ENABLED`，之后重新启动您的 Pi，该操作将会重新连接 WiFi。
    * If you are using a WiFi network with a *hidden SSID*, edit `/boot/wpa_supplicant.conf.sample` and uncomment the line `scan_ssid=1` in the `network={...}` block.
  * If still no go, re-run `/etc/rc.local`
  * If all else fails, copy `/boot/wpa_supplicant.conf.sample` to `/boot/wpa_supplicant.conf` and edit out the `TEMP` variables to your desired settings.
* Note: if you get an error about `read-only filesystem`, you may have to `sudo -i` and run `/root/bin/remountfs_rw`.

More troubleshooting information in the [wiki](https://github.com/lndj/teslausb/wiki/Troubleshooting)

# Background information
## What happens under the covers

When the Pi boots the first time:
* A `/boot/teslausb-headless-setup.log` file will be created and stages logged.
* Marker files will be created in `boot` like `TESLA_USB_SETUP_STARTED` and `TESLA_USB_SETUP_FINISHED` to track progress.
* Wifi is detected by looking for `/boot/WIFI_ENABLED` and if not, creates the `wpa_supplicant.conf` file in place, using `SSID` and `WIFIPASS` from `teslausb_setup_variables.conf` and reboots.
* The Pi LED will flash patterns (2, 3, 4, 5) as it gets to each stage (labeled in the setup-teslausb script).
* After the final stage and reboot the LED will go back to normal. Remember, the step to remount the filesystem takes a few minutes.

At this point the next boot should start the Dashcam/music drives like normal. If you're watching the LED it will start flashing every 1 second, which is the archive loop running.

> NOTE: Don't delete the `TESLAUSB_SETUP_FINISHED` or `WIFI_ENABLED` files. This is how the system knows setup is complete.

# Image modification sources

The sources for the image modifications, and instructions, are in the [pi-gen-sources folder](https://github.com/lndj/teslausb/tree/main-dev/pi-gen-sources).
