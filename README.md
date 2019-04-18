# koha-plugin-check-sms-numbers
This Koha plugin gives ability to check the format of SMS numbers in database
It was created for the Bug 19017:
Bug 19017: Script that checks and transforms SMS alert numbers

With this Koha plugin, you can choose a country, then the plugin show you the extensions for this country.
Exemple : in France you have +33, 0033
you can choose an extension and search, the plugin give you all the numbers who are invalid, that means :
if you choose +33 : +33640302920 is a valid number,0640302920 is an invalid number.
You can choose the numbers that you want to tranform numbers with the extension you have chosen
And then see the result

For now, there is only the country : France that is available. 
