#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда  

#Область ОбработчикиСобытийМодуляОбъекта
 
Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	 
	 Для каждого Строка Из СписокСотрудников Цикл
        Если Месяц(Строка.ДатаНачала) <> Месяц(Строка.ДатаОкончания) Тогда
            Сообщить (СтрШаблон("Не верно задан период в строке №%1", Строка.НомерСтроки)); 
            Отказ = Истина; 
        КонецЕсли;
    КонецЦикла;  
    
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим) 
	
	СформироватьДвижения();
	
	РасчетОклада(); 
	
	РасчетОтпуска();  
	
	РасчетУдержаний(); 
      	
	СформироватьДвиженияВзаиморасчетыССотрудниками(); 
	
	СформироватьДвиженияЗапланированныеОтпуска();
	
КонецПроцедуры  

#КонецОбласти

#Область СлужебныеПроцедурыФункции  

Процедура СформироватьДвижения() 
	 
	 СформироватьДвиженияОсновныеНачисления(); 
	 
	 СформироватьДвиженияУдержания();
	 
	 СформироватьСторноЗаписи();
	 
	 Движения.ВКМ_ОсновныеНачисления.Записать(); 
	 
КонецПроцедуры
 
Процедура СформироватьДвиженияОсновныеНачисления() 
	
	Если СписокСотрудников.Количество()=0 Тогда
		Возврат;	
	КонецЕсли;   
	
	МинимальнаяДатаНачала = Неопределено; 
	МаксимальнаяДатаОкончания = Неопределено; 
	
	Для каждого Строка Из СписокСотрудников Цикл
		Если Не ЗначениеЗаполнено(МинимальнаяДатаНачала) 
			ИЛИ МинимальнаяДатаНачала > Строка.ДатаНачала Тогда
			МинимальнаяДатаНачала = Строка.ДатаНачала; 
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(МаксимальнаяДатаОкончания) 
			ИЛИ МаксимальнаяДатаОкончания < Строка.ДатаОкончания  Тогда
			МаксимальнаяДатаОкончания = Строка.ДатаОкончания; 
		КонецЕсли;
	КонецЦикла;  
	
	Движения.ВКМ_ОсновныеНачисления.Записывать = Истина; 
	Движения.ВКМ_Удержания.Записывать = Истина; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_НачислениеЗарплатыСотрудники.Сотрудник КАК Сотрудник,
		|	ВКМ_НачислениеЗарплатыСотрудники.ВидРасчета КАК ВидРасчета,
		|	ВКМ_НачислениеЗарплатыСотрудники.ДатаНачала КАК ДатаНачала,
		|	ВКМ_НачислениеЗарплатыСотрудники.ДатаОкончания КАК ДатаОкончания,
		|	ВКМ_НачислениеЗарплатыСотрудники.ГрафикРаботы КАК ГрафикРаботы,
		|	ВКМ_НачислениеЗарплаты.Подразделение КАК Подразделение
		|ПОМЕСТИТЬ ВТ_ДанныеДокумента
		|ИЗ
		|	Документ.ВКМ_НачислениеЗарплаты.СписокСотрудников КАК ВКМ_НачислениеЗарплатыСотрудники
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВКМ_НачислениеЗарплаты КАК ВКМ_НачислениеЗарплаты
		|		ПО ВКМ_НачислениеЗарплатыСотрудники.Ссылка = ВКМ_НачислениеЗарплаты.Ссылка
		|ГДЕ
		|	ВКМ_НачислениеЗарплатыСотрудники.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Оклад КАК Оклад,
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот КАК ПроцентОтРабот,
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Подразделение КАК Подразделение
		|ПОМЕСТИТЬ ВТ_ОкладПроцент
		|ИЗ
		|	РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(
		|			&ДатаНачала,
		|			Сотрудник В
		|				(ВЫБРАТЬ
		|					ВТ_ДанныеДокумента.Сотрудник КАК Сотрудник
		|				ИЗ
		|					ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента)) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВКМ_ВыполненныеСотрудникомРаботыОбороты.СуммаКОплатеОборот КАК СуммаКОплатеОборот,
		|	ВКМ_ВыполненныеСотрудникомРаботыОбороты.Сотрудник КАК Сотрудник
		|ПОМЕСТИТЬ ВТ_ПроцентОтРабот
		|ИЗ
		|	РегистрНакопления.ВКМ_ВыполненныеСотрудникомРаботы.Обороты(
		|			&ДатаНачала,
		|			&ДатаОкончания,
		|			,
		|			Сотрудник В
		|				(ВЫБРАТЬ
		|					ВТ_ДанныеДокумента.Сотрудник КАК Сотрудник
		|				ИЗ
		|					ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента)) КАК ВКМ_ВыполненныеСотрудникомРаботыОбороты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ДанныеДокумента.Сотрудник КАК Сотрудник,
		|	ВТ_ДанныеДокумента.ВидРасчета КАК ВидРасчета,
		|	ВТ_ДанныеДокумента.ДатаНачала КАК ДатаНачала,
		|	ВТ_ДанныеДокумента.ДатаОкончания КАК ДатаОкончания,
		|	ВТ_ДанныеДокумента.ГрафикРаботы КАК ГрафикРаботы,
		|	ВЫБОР
		|		КОГДА ВТ_ДанныеДокумента.ВидРасчета = &Оклад 
		|			ТОГДА ВТ_ОкладПроцент.Оклад
		|		КОГДА ВТ_ДанныеДокумента.ВидРасчета = &ПроцентОтРабот 
		|			ТОГДА ВТ_ОкладПроцент.ПроцентОтРабот
		|		ИНАЧЕ НЕОПРЕДЕЛЕНО
		|	КОНЕЦ КАК Показатель,
		|	-ВТ_ПроцентОтРабот.СуммаКОплатеОборот КАК СуммаПроцентовЗаРаботу
		|ИЗ
		|	ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОкладПроцент КАК ВТ_ОкладПроцент
		|		ПО ВТ_ДанныеДокумента.Сотрудник = ВТ_ОкладПроцент.Сотрудник
		|			И ВТ_ДанныеДокумента.Подразделение = ВТ_ОкладПроцент.Подразделение
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ПроцентОтРабот КАК ВТ_ПроцентОтРабот
		|		ПО ВТ_ДанныеДокумента.Сотрудник = ВТ_ПроцентОтРабот.Сотрудник";
	
	Запрос.УстановитьПараметр("ДатаНачала", МинимальнаяДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", МаксимальнаяДатаОкончания);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);   
	Запрос.УстановитьПараметр("Оклад", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад);
	Запрос.УстановитьПараметр("ПроцентОтРабот", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.ПроцентОтРабот);

	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновныеНачисления.Добавить(); 
		Движение.ПериодРегистрации = Дата;  
		Движение.Подразделение = Подразделение; 
		Движение.ВидРасчета = Выборка.ВидРасчета;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.ГрафикРаботы = Выборка.ГрафикРаботы; 
		Движение.ПериодДействияНачало = Выборка.ДатаНачала; 
		Движение.ПериодДействияКонец = Выборка.ДатаОкончания; 
		Движение.Показатель = Выборка.Показатель; 
		
		Если Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск Тогда
		   Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(Движение.ПериодДействияНачало, -12)); 
		   Движение.БазовыйПериодКонец = КонецМесяца(ДобавитьМесяц(Движение.БазовыйПериодНачало, 11)); 
		   Движение.ДнейОтработано = (Движение.ПериодДействияКонец - Движение.ПериодДействияНачало)/86400 + 1; 
           Движение.Показатель = Неопределено; 
		КонецЕсли; 
	   
	   Если Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.ПроцентОтРабот Тогда
	       Движение.Показатель = Выборка.Показатель; 
		   Движение.Сумма = Выборка.СуммаПроцентовЗаРаботу;    
		   Движение.ДнейОтработано = Неопределено; 
	   КонецЕсли;    

   КонецЦикла; 
   
   Движения.ВКМ_ОсновныеНачисления.Записать(); 
	
КонецПроцедуры  

Процедура СформироватьДвиженияУдержания()	

	Запрос = Новый Запрос;
	Запрос.Текст = 
	  "ВЫБРАТЬ РАЗЛИЧНЫЕ
	 |	ВКМ_НачислениеЗарплатыСотрудники.Сотрудник КАК Сотрудник
	 |ИЗ
	 |	Документ.ВКМ_НачислениеЗарплаты.СписокСотрудников КАК ВКМ_НачислениеЗарплатыСотрудники
	 |ГДЕ
	 |	ВКМ_НачислениеЗарплатыСотрудники.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.Сотрудник = Выборка.Сотрудник;  
		Движение.Подразделение = Подразделение; 
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
	КонецЦикла; 
	
	Движения.ВКМ_Удержания.Записать(); 
	
КонецПроцедуры

Процедура СформироватьСторноЗаписи() 
	
	СторноЗаписи = Движения.ВКМ_ОсновныеНачисления.ПолучитьДополнение();
	
	Для каждого Запись  Из СторноЗаписи Цикл
	
		Движение = Движения.ВКМ_ОсновныеНачисления.Добавить(); 
		ЗаполнитьЗначенияСвойств(Движение, Запись); 
		Движение.ПериодРегистрации = Дата; 
		Движение.ПериодДействияНачало = Запись.ПериодДействияНачалоСторно; 
		Движение.ПериодДействияКонец = Запись.ПериодДействияКонецСторно; 
		Движение.Сторно = Истина; 
	
	КонецЦикла;

КонецПроцедуры

Процедура РасчетОклада()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ДнейПериодДействия, 0) КАК План,
		|	ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ДнейФактическийПериодДействия, 0) КАК Факт,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.Подразделение КАК Подразделение,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.ВидРасчета КАК ВидРасчета,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
		|			ВидРасчета = &Оклад
		|				И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияДанныеГрафика";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка); 
	Запрос.УстановитьПараметр("Оклад", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад);

	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();     
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1]; 
        Движение.ДнейОтработано = Выборка.Факт; 
		Движение.Сумма =  Движение.Показатель * Выборка.Факт / Выборка.План;    
        
        Если Движение.Сторно Тогда
            Движение.ДнейОтработано = - Движение.ДнейОтработано; 
            Движение.Сумма = - Движение.Сумма; 
        КонецЕсли;
	КонецЦикла;
	
    Движения.ВКМ_ОсновныеНачисления.Записать(, Истина); 	

КонецПроцедуры

Процедура РасчетОтпуска()

    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |   ВКМ_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
        |   ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
        |   ВКМ_ОсновныеНачисления.ВидРасчета КАК ВидРасчета,
        |   ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ДнейОтработано, 0) КАК ДнейОтпуска,
        |   ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.СуммаБаза, 0) КАК СуммаНачислений,
        |   ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ДнейБазовыйПериод, 0) КАК ОтработаноДней
        |ИЗ
        |   РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
        |       ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.БазаВКМ_ОсновныеНачисления(
        |               &Измерения,
        |               &Измерения,
        |               ,
        |               ВидРасчета = &Отпуск
        |                   И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления
        |       ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.НомерСтроки
        |       ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
        |               ВидРасчета = &Отпуск
        |                   И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
        |       ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки
        |ГДЕ
        |   ВКМ_ОсновныеНачисления.ВидРасчета = &Отпуск
        |   И ВКМ_ОсновныеНачисления.Регистратор = &Ссылка";
    
    Измерения = Новый Массив; 
    Измерения.Добавить("Сотрудник"); 
    Измерения.Добавить("Подразделение"); 
    Запрос.УстановитьПараметр("Измерения", Измерения);
    Запрос.УстановитьПараметр("Отпуск", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск);
    Запрос.УстановитьПараметр("Ссылка", Ссылка);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    Выборка = РезультатЗапроса.Выбрать();
    
    Пока Выборка.Следующий() Цикл
        	
        Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1]; 
        Движение.Показатель = Выборка.СуммаНачислений / Выборка.ОтработаноДней; 
        Движение.Сумма = Движение.Показатель * Выборка.ДнейОтпуска; 
		
		Если Движение.Сторно Тогда
		   Движение.Сумма = - Движение.Сумма; 
		КонецЕсли;
        
    КонецЦикла;
    
    Движения.ВКМ_ОсновныеНачисления.Записать(, Истина); 
    
КонецПроцедуры

Процедура РасчетУдержаний()
	
	Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ
    |	ВКМ_Удержания.НомерСтроки КАК НомерСтроки,
    |	ЕСТЬNULL(ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.СуммаБаза, 0) КАК СуммаБаза
    |ИЗ
    |	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
    |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания.БазаВКМ_ОсновныеНачисления(
    |				&Измерения,
    |				&Измерения,
    |				,
    |				Регистратор = &Ссылка
    |					И ВидРасчета = &ВидРасчета) КАК ВКМ_УдержанияБазаВКМ_ОсновныеНачисления
    |		ПО ВКМ_Удержания.НомерСтроки = ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.НомерСтроки
    |ГДЕ
    |	ВКМ_Удержания.Регистратор = &Ссылка"; 
    
	Измерение = Новый Массив; 
	Измерение.Добавить("Сотрудник");  
	Измерение.Добавить("Подразделение"); 
	    
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Измерения", Измерение); 
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_Удержания.НДФЛ); 
		
    РезультатЗапроса = Запрос.Выполнить();
    
    Выборка = РезультатЗапроса.Выбрать();
    
    Пока Выборка.Следующий() Цикл   
		Движение = Движения.ВКМ_Удержания[Выборка.НомерСтроки - 1]; 
		Движение.Сумма = Выборка.СуммаБаза * 13 / 100; 
    КонецЦикла;
    
    Движения.ВКМ_Удержания.Записать(,Истина); 
   
КонецПроцедуры

Процедура СформироватьДвиженияВзаиморасчетыССотрудниками() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
        |   ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
        |   ВКМ_ОсновныеНачисления.Подразделение КАК Подразделение,
        |   СУММА(ВКМ_ОсновныеНачисления.Сумма) КАК Оклад,
        |   ВКМ_Удержания.Сумма КАК НДФЛ
        |ИЗ
        |   РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
        |       ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
        |       ПО ВКМ_ОсновныеНачисления.Сотрудник = ВКМ_Удержания.Сотрудник
        |ГДЕ
        |   ВКМ_ОсновныеНачисления.Регистратор = &Ссылка
        |   И ВКМ_Удержания.Регистратор = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |   ВКМ_ОсновныеНачисления.Сотрудник,
        |   ВКМ_ОсновныеНачисления.Подразделение,
        |   ВКМ_Удержания.Сумма
        |ИТОГИ
        |   СУММА(Оклад),
        |   СУММА(НДФЛ)
        |ПО
        |   Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();  
	
	Выборка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Сотрудник");
	
	Пока Выборка.Следующий() Цикл   
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить(); 
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход; 
		Движение.Период = Дата; 
		Движение.Подразделение = Подразделение; 
		Движение.Сотрудник = Выборка.Сотрудник; 
		Движение.Сумма = Выборка.Оклад - Выборка.НДФЛ; 
	КонецЦикла;
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();

КонецПроцедуры

Процедура СформироватьДвиженияЗапланированныеОтпуска()
	
	Движения.ВКМ_ЗапланированныеОтпуска.Записывать = Истина;
		
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_НачислениеЗарплатыСписокСотрудников.Сотрудник,
	|	ВКМ_НачислениеЗарплатыСписокСотрудников.ДатаНачала,
	|	ВКМ_НачислениеЗарплатыСписокСотрудников.ДатаОкончания,
	|	РАЗНОСТЬДАТ(ВКМ_НачислениеЗарплатыСписокСотрудников.ДатаНачала,
	|		ВКМ_НачислениеЗарплатыСписокСотрудников.ДатаОкончания, ДЕНЬ) + 1 КАК КоличествоДней
	|ИЗ
	|	Документ.ВКМ_НачислениеЗарплаты.СписокСотрудников КАК ВКМ_НачислениеЗарплатыСписокСотрудников
	|ГДЕ
	|	ВКМ_НачислениеЗарплатыСписокСотрудников.Ссылка = &Ссылка
	|	И ВКМ_НачислениеЗарплатыСписокСотрудников.ВидРасчета = &ВидРасчета";
	
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		Движение = Движения.ВКМ_ЗапланированныеОтпуска.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход; 
		Движение.Период = Дата;
		Движение.Сотрудник = Результат.Сотрудник;
		Движение.ДатаНачала = Результат.ДатаНачала;
		Движение.ДатаОкончания = Результат.ДатаОкончания;
		Движение.КоличествоДнейОтпуска = Результат.КоличествоДней;
	КонецЦикла;	
	
	
КонецПроцедуры

#КонецОбласти     

#КонецЕсли