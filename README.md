# block4YC

## (in English)

This batch file is intended to start and configure Windows Defender firewall
in such a way that any external resouces except ext.contest.yandex.{ru,com} and what it is depended on will not be available.

The batch file is generating unblocking batch file during execution.

The unblocking batch file will revert changes. To do so it need *.wfw file generated by block4yc.

## (на русском)

Этот пакетный файл предназначен для запуска и настройки брандмауэра Windows Defender таким способом что никакие внешние ресурсы за исключением ext.contest.yandex.{ru,com} и тех, от которых он зависит, не будут доступны.

Этот файл генерирует пакетный файл для снятия блокировки в процессе своего выполнения.

Разблокирующий пакетный файл отменяет изменения. Для этого ему нужен файл *.wfw, сгенерированный block4yc.