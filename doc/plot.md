# Сценарий игры ITMMORGUE

## Сюжетная линия 

Весь мир генерируется целиком и полностью в начальный момент.

## Игровая механика

### Бег и ходьба
  * cells_i = floor(speed_i) + (rnd() < (speed_i - floor(speed_i))), где rnd() -- рандом uniform от 0..1
  * при движении игрока 7913(numpad): delta_x = delta_y = cells(speed / sqrt(2))
  * при движении спеллов, стрел, летающих объектов: cells_i(), а попадание в цель наступает только при пересечении с возможной целью
  * speed == 1 -- ходьба, speed > 1 -- бег. Переключается модификатором
  * либо бежим, либо идём. Среднего не дано
  * бег тратит стамину
    * при маленькой стамине бег не работает, надо передохнуть
  * вес переносимых предметов плавно уменьшает скорость до 1
  * перегрузка делает speed = 0

## Система скиллов

* любой игрок может юзать любой скилл
  * в зависимости от умений персонажа выбирается эффект скилла
  * скилл может нанести урон или иметь отрицательный эффект при низком уровне владения

## Относится к игрокам

### Система рас, родов и классов

Рас, родов и классов не будет.
Специализация прокачивается пассивно в зависимости от используемых скиллов.

### Система вещей

В начале игры все могут выбрать некоторое количество предметов на стартовую сумму денег.
Эти предметы повышают соответствющие умения до некоторого небольшого уровня владения, чтобы не наносить урон владельцу при их использовании.

## Неигровые персонажи implements Movable

* агрессия мобов
  * в зависимости от действий игрока
  * в зависимости от качеств игрока (навыки, снаряжение, скиллы, баффы(?))
  * в зависимости от лояльности (взаимоотношение с игровым миром) игрока(?), группы(?)
* страх мобов
  * оценка вероятных противников
* оценка своей победы в битве -- нужно бежать, игнорировать или атаковать
* внутриигровое уведомление при смерти сюжетных мобов
* имеют флаг: "сюжетный"
* возможность (флаг) повлиять на main routine других мобов (напр. купить что-то у торговца)

### Main routine

Должен быть стэк из листов рутин. Например, лист -- догнать лису + убить лису.
У рутины есть ИД зависимой рутины. При завершении рутины завершаются все её потомки каскадно.

* стоять на месте
* ходить в пределах заданной области (как задавать область?): торговец на рынке или лиса в лесу
  * область относительно чанков (строений, городов, опушек)
  * область может быть составной (вложенной)
* бежать по своим делам (сюжет, бот, заранее продуманные кейсы)
* патрулировать заданный по waypoint путь
* следовать за персонажем

#### Сопровождение игроков

* проявлять агрессию к мобам
  * на основе агрессии и страха
  * в зависимости от основной рутины (если он ведомый под защитой, в атаку не полезет)
* подстраивается под скорость
  * может умышленно опережать
  * может умышленно отставать
  * может стараться идти в темпе следуемого объекта
* в случае следования за группой вычисляется средняя точка от всех членов группы (половинным делением например), от этой точки определяется самый удаленный игрок и если расстояние до него не превышает порога, то следовать надо за группой вцелом
* если игрок отделяется от группы, то моб:
  * продолжает следовать за остальной группой
  * будет уходить вместе с отделившимся игроком (помогает одиночке при нечетном кол-ве игроков)
  * мобу можно крикнуть "follow me"

### Special routine

Сложная последовательность действий, в основном, описывающая действия сюжетных персонажей.

### Микротаски

Генерируются основной рутиной. Например:
* открыть дверь
* дойти в точку
* обойти болото
* ждать
* переключиться на бег
* сдвинуться в направлении

Некоторые сюжетные микротаски (напр. скрафтить хитрый меч-леденец) выдаются только в рамках special routine.

## Описание местности

* у каждой клеточки есть битовая карта принадлежности к областям (uint64: магазин, рынок, город, лес, поверхность, пещера)
* у каждого моба есть принадлежность к области в изначальной рутине (напр. торговец заспавнился тут, буду обитать тут)
* мобы спавнятся в своей домашней области
* область спавнит мобов на ней

* ~10**6+ общая площадь = клеток для перемещения: поверхность (58%) и пещеры (42%)
* 94% поверхности = леса (75%) + равнины (25%)
* 6% поверхности = города (каждый город не менее 48х48 клеток)
* в пещере 1-5 уровней
  * в пещере с равным распределением комнат 50% составляют стены
* мобы
  * на поверхности:
    * 1 на 2000 клеток^2
    * 1 на 30 клеток
  * в пещерах:
    * 1 на 10 клеток^2
    * 1 на 4 клетки
* обо всех городах должна быть метаинформация
  * направление, которое можно найти по слухам, по картам, указатели, ...
  * никому не известные места (поселения, ...)

## Боевая система

* friendly fire
  * любой массовый урон необходимо распределять по всей площади, включая friendly fire (как игрок-игрок, так и монстр-монстр)
  * необходимо продумать скорость/перемещение, чтобы была возможность заманивать одних монстров под атаки других

## Интерфейс

Окно можно растягивать.
Карта видна во всём окне.
Мобы видны только в радиусе видимости (параметр игрока).
Интерфейс карты занимает всё окно.
* карта ведется только если у игрока есть листы бумаги (TODO еще она может намокнуть)
* в любое время можно посмотреть на свою карту
