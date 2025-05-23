// {{Борисова А.В.
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриОткрытии(Отказ)
	Если Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание") Тогда
		Элементы.ПолеАбонентскаяПлата.Видимость  	= Истина;
    	Элементы.ПолеНачалоДействия.Видимость  	 	= Истина;
 		Элементы.ПолеОкончаниеДействия.Видимость  	= Истина;
		Элементы.ПолеСтоимостьЧасаРаботы.Видимость 	= Истина; 
	Иначе
		Элементы.ПолеАбонентскаяПлата.Видимость  	= Ложь;
    	Элементы.ПолеНачалоДействия.Видимость  	 	= Ложь;
 		Элементы.ПолеОкончаниеДействия.Видимость  	= Ложь;
		Элементы.ПолеСтоимостьЧасаРаботы.Видимость 	= Ложь;  
	КонецЕсли;	

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;	
	ВидДоговораПриИзмененииНаСервере() ;
	Если Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание") Тогда
		Элементы.ПолеАбонентскаяПлата.Видимость  	= Истина;
    	Элементы.ПолеНачалоДействия.Видимость  	 	= Истина;
 		Элементы.ПолеОкончаниеДействия.Видимость  	= Истина;
		Элементы.ПолеСтоимостьЧасаРаботы.Видимость 	= Истина; 
	Иначе
		Элементы.ПолеАбонентскаяПлата.Видимость  	= Ложь;
    	Элементы.ПолеНачалоДействия.Видимость  	 	= Ложь;
 		Элементы.ПолеОкончаниеДействия.Видимость  	= Ложь;
		Элементы.ПолеСтоимостьЧасаРаботы.Видимость 	= Ложь;  
	КонецЕсли;	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаСервере
Процедура ВидДоговораПриИзмененииНаСервере()
	
	ДобавлениеРеквизитов = Элементы.Добавить("ПолеАбонентскаяПлата",Тип("ПолеФормы"),ЭтотОбъект);	
	ДобавлениеРеквизитов.Вид = ВидПоляФормы.ПолеВвода;
	ДобавлениеРеквизитов.ПутьКДанным = "Объект.ВКМ_АбонентскаяПлата";
	
	ДобавлениеРеквизитов = Элементы.Добавить("ПолеНачалоДействия",Тип("ПолеФормы"),ЭтотОбъект);	
	ДобавлениеРеквизитов.Вид = ВидПоляФормы.ПолеВвода;
	ДобавлениеРеквизитов.ПутьКДанным = "Объект.ВКМ_НачалоДействия";
	
	ДобавлениеРеквизитов = Элементы.Добавить("ПолеОкончаниеДействия",Тип("ПолеФормы"),ЭтотОбъект);	
	ДобавлениеРеквизитов.Вид = ВидПоляФормы.ПолеВвода;
	ДобавлениеРеквизитов.ПутьКДанным = "Объект.ВКМ_ОкончаниеДействия";
	
	ДобавлениеРеквизитов = Элементы.Добавить("ПолеСтоимостьЧасаРаботы",Тип("ПолеФормы"),ЭтотОбъект);	
	ДобавлениеРеквизитов.Вид = ВидПоляФормы.ПолеВвода;
	ДобавлениеРеквизитов.ПутьКДанным = "Объект.ВКМ_СтоимостьЧасаРаботы";
КонецПроцедуры
#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
&НаКлиенте
Процедура ВидДоговораПриИзменении(Элемент)
	
	Если Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание") Тогда
			Элементы.ПолеАбонентскаяПлата.Видимость	 	= Истина;
    		Элементы.ПолеНачалоДействия.Видимость  	 	= Истина;
			Элементы.ПолеОкончаниеДействия.Видимость  	= Истина;
			Элементы.ПолеСтоимостьЧасаРаботы.Видимость 	= Истина;  	
	Иначе
			Элементы.ПолеАбонентскаяПлата.Видимость  	= Ложь;
    		Элементы.ПолеНачалоДействия.Видимость  	 	= Ложь;
 			Элементы.ПолеОкончаниеДействия.Видимость  	= Ложь;
			Элементы.ПолеСтоимостьЧасаРаботы.Видимость 	= Ложь;   	 
	КонецЕсли;

КонецПроцедуры
#КонецОбласти
//Борисова А.В.}}
