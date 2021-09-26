#!/bin/bash

export TERM=ansi;
TITLE="RPI 0 USB CA";
LINES=$1;
COLUMNS=$2;
MENU_HEIGHT=$(expr $LINES - 8);

function getSubj {
    whiptail --title "$TITLE" --inputbox "Kraj: (dwuliterowy kod)" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS AU 2>subjC.output;
    if [ $? -ne 0 ]; then return 1; fi
    whiptail --title "$TITLE" --inputbox "Województwo/Stan: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS Some-State 2>subjST.output;
    if [ $? -ne 0 ]; then return 1; fi
    whiptail --title "$TITLE" --inputbox "Nazwa lokalizcji, np. miasto:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS Some-City 2>subjL.output;
    if [ $? -ne 0 ]; then return 1; fi
    if [ -f newCAname.output ]; then
        whiptail --title "$TITLE" --inputbox "Nazwa organizacji: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS $(cat newCAname.output) 2>subjO.output;
        if [ $? -ne 0 ]; then return 1; fi
    else 
        whiptail --title "$TITLE" --inputbox "Nazwa organizacji: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS "Internet Widgits Pty Ltd." 2>subjO.output;
        if [ $? -ne 0 ]; then return 1; fi
    fi
    whiptail --title "$TITLE" --inputbox "Nazwa działu: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS "Dział IT" 2>subjOU.output;
    if [ $? -ne 0 ]; then return 1; fi
    if [ -f newCAname.output ]; then
        whiptail --title "$TITLE" --inputbox "Nazwa powszechna: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS $(cat newCAname.output) 2>subjCN.output;
        if [ $? -ne 0 ]; then return 1; fi
    else
        whiptail --title "$TITLE" --inputbox "Nazwa powszechna: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ca.example.com 2>subjCN.output;
        if [ $? -ne 0 ]; then return 1; fi
    fi
}

if [ $(whoami) = "root" ]; then

    if which openssl > /dev/null; then 

        whiptail --title "$TITLE" --msgbox "Pakiet OpenSSL jest dostępny w systemie" 8 $COLUMNS;
        while [ true ]; do

            whiptail --title "$TITLE" --menu "Aby rozpocząć wybierz jedną z opcji:" --cancel-button "Wyjście do powłoki" $LINES $COLUMNS $(expr $LINES - 8) \
            "Nowe CA" "Utwórz nowy urząd certyfikacji" \
            "Klucz CA" "Utwórz klucz urzędu certyfikacji" \
            "Certyfikat CA" "Utwórz certyfikat CA" \
            "Klucz prywatny" "Utwórz nowy klucz prywatny" \
            "Generuj wniosek" "Wygeneruj nowy wniosek o certyfikat" \
            "Podpisz wniosek" "Wygeneruj certyfikat podpisując wniosek za pomocą CA" \
            "Ściągnij hasło" "Ściagnij hasło z klucza prywatnego" \
            "Unieważnij certyfikat" "Wyłącz certyfikat z użytku za pomocą CA" \
            "Generuj CRL" "Generowanie listy unieważnionych certyfikatów" \
            "Sprawdź certyfikat" "Sprawdź ważność lub unieważnienie certyfikatu" \
            "Konwersje" "Zmiana formatu wygenrowanego certyfikatu" \
            "Konfiguruj dostęp" "Skonfigruj dostęp aby móc pobrać certyfikaty" \
            "Wyjście" "Zakończ pracę i wyłącz RPI" 2> mainMenu.output;

            menuOption=$(cat mainMenu.output);

            rm mainMenu.output;

            case $menuOption in

                "Nowe CA") whiptail --title "$TITLE" --inputbox "Nazwa organizacji:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS "Internet Widgits Pty Ltd." 2> newCAname.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Katalog główny:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS /etc/ssl 2> newCAdir.output;
                            if [ $? -ne 0 ]; then continue; fi
                            dir=$(cat newCAdir.output);
                            whiptail --title "$TITLE" --inputbox "Katalog certyfikatow:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/certs 2> newCAcerts.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Katalog z listą unieważnionych certyfikatów:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/crl 2> newCAcrl_dir.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Katalog nowych certyfikatów podpisanych przez CA:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/cacert.pem 2>newCAnewcertsdir.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Klucz prywatny CA:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/private/cakey.pem 2>newCAprivate_key.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Baza w której przechowywane o wystawionych cert. wraz ze statusem:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/index.txt 2>newCAdatabase.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Certyfikat CA - do podpisu wniosków:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/cacert.pem 2>newCAcertificate.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Plik pomocniczy z bierzącym numerem - inkrementowany po każdym wystawieniu certyfikatu: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/serial 2> newCAserial.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Bierząca lista unieważnionych certyfikatów:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS ${dir}/crl.pem 2>newCAcrl.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Punkt dystrybucji listy crl:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS URI:https://example.com/crl.pem 2>newCAcrldistributionpoint.output;

                            echo "[ ca ]" > openssl.cnf
                            echo "default_ca = CA_$(cat newCAname.output)" >> openssl.cnf
                            echo "[ CA_$(cat newCAname.output) ]" >> openssl.cnf;
                            echo >> openssl.cnf
                            echo "dir = $(cat newCAdir.output)" >> openssl.cnf;
                            echo "certs = $(cat newCAcerts.output)" >> openssl.cnf;
                            echo "crl_dir = $(cat newCAcrl_dir.output)" >> openssl.cnf;
                            echo "new_certs_dir = $(cat newCAnewcertsdir.output)" >> openssl.cnf;
                            echo "private_key = $(cat newCAprivate_key.output)" >> openssl.cnf;
                            echo "database = $(cat newCAdatabase.output)" >> openssl.cnf;
                            echo "certificate = $(cat newCAcertificate.output)" >> openssl.cnf;
                            echo "serial = $(cat newCAserial.output)" >> openssl.cnf;
                            echo "crl = $(cat newCAcrl.output)" >> openssl.cnf;
                            echo >> openssl.cnf;
                            echo "default_days = 356" >> openssl.cnf;
                            echo "default_crl_days = 30" >> openssl.cnf;
                            echo "default_md = default" >> openssl.cnf;
                            echo "preserve = no" >> openssl.cnf;
                            echo >> openssl.cnf;
                            echo "policy = policy_match" >> openssl.cnf;
                            echo >> openssl.cnf;
                            echo "[ policy_match ]" >> openssl.cnf;
                            echo "countryName  =  match" >> openssl.cnf;
                            echo "stateOrProvinceName = match" >> openssl.cnf;
                            echo "organizationName = match" >> openssl.cnf;
                            echo "organizationalUnitName = optional" >> openssl.cnf;
                            echo "commonName = supplied" >> openssl.cnf;
                            echo "emailAddress = optional" >> openssl.cnf;
                            echo >> openssl.cnf;
                            echo "[ v3_ca ]" >> openssl.cnf;
                            echo "crlDistributionPoints=$(cat newCAcrldistributionpoint.output)" >> openssl.cnf;

                            whiptail --title "$TITLE" --textbox openssl.cnf $LINES $COLUMNS;

                            whiptail --title "$TITLE" --yesno "Wdrożyć stworzony plik openssl.cnf" 8 $COLUMNS;

                            if [ $? -eq 0 ]; then
                                if [ ! -f /etc/ssl/openssl.cnf.init ]; then cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.init; fi
                                cat openssl.cnf >> /etc/ssl/openssl.cnf;

                                touch $(cat newCAdir.output)/index.txt;
                                sh -c 'echo 00 > $(cat newCAdir.output)/serial';
                                if [ ! -d $(cat newCAcrl_dir.output) ]; then mkdir $(cat newCAcrl_dir.output); fi
                                if [ ! -d $(cat newCAnewcertsdir.output) ]; then mkdir $(cat newCAnewcertsdir.output); fi
                                if [ ! -d ${dir}/private ]; then mkdir ${dir}/private; fi
                                if [ ! -d ${dir}/certs ]; then mkdir ${dir}/private; fi
                            fi;;

                "Klucz CA") 
                            whiptail --title "$TITLE" --passwordbox "Wprowadź hasło klucza prywatnego CA:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>keyCApassword.output;
                            if [ $? -ne 0 ]; then continue; fi
                            whiptail --title "$TITLE" --inputbox "Wprowadź długość klucza prywatnego CA:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>keyCABits.output;
                            if [ $? -ne 0 ]; then continue; fi

                            keyCApassword=$(cat keyCApassword.output);
                            keyCALocation=$(cat openssl.cnf | grep "^private_key\ =" | cut -d " " -f 3);

                            whiptail --title "$TITLE" --infobox "Generowanie klucza prywatnego" 8 $LINES;
                            openssl genrsa -des3 -passout pass:$keyCApassword -out ${keyCALocation} $(cat keyCABits.output);
                            if [ $? -eq 0 ]; then 
                                whiptail --title "$TITLE" --msgbox "Pomyślnie wygenerowano klucz prywatny CA." 8 $COLUMNS;
                            else 
                                whiptail --title "$TITLE" --msgbox "Generowanie klucza nie powiodło się." 8 $COLUMNS;
                            fi;; 
                "Certyfikat CA") 
                                keyCALocation=$(cat openssl.cnf | grep "^private_key\ =" | cut -d " " -f 3);
                                certCALocation=$(cat openssl.cnf | grep "^certificate\ =" | cut -d " " -f 3);

                                getSubj;

                                whiptail --title "$TITLE" --passwordbox "Wprowadź hasło klucza prywatnego CA:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>keyCApassword.output;

                                #echo "" > certCa.txt;

                                #whiptail --title "$TITLE" --textbox certCa.txt 8 $COLUMNS;;

                                openssl req -new -x509 -days 365 -subj "/C=$(cat subjC.output)/ST=$(cat subjST.output)/L=$(cat subjL.output)/O=$(cat subjO.output)/OU=$(cat subjOU.output)/CN=$(cat subjCN.output)" -key ${keyCALocation} -passin pass:$(cat keyCApassword.output) -out ${certCALocation};

                                if [ $? -eq 0 ]; then
                                    whiptail --title "$TITLE" --msgbox "Pomyślnie wygenerowano certyfikat CA." 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Generowanie certyfikatu CA nie powiodło się." 8 $COLUMNS;
                                fi;;
                "Klucz prywatny")
                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę dla pliku klucza prywatnego: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS "private/" 2>privKeyFilename.output;
                                if [ $? -ne 0 ]; then continue; fi
                                whiptail --title "$TITLE" --passwordbox "Wprowadź hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>privKeypassword.output;
                                if [ $? -ne 0 ]; then continue; fi
                                whiptail --title "$TITLE" --inputbox "Podaj długość klucza prywatnego: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 1024 2>privKeyBitsLength.output;
                                if [ $? -ne 0 ]; then continue; fi

                                dirLocation=$(cat openssl.cnf | grep "^dir\ =\ " | cut -d " " -f 3);

                                openssl genrsa -des3 -out ${dirLocation}/$(cat privKeyFilename.output) -passout pass:$(cat privKeypassword.output) $(cat privKeyBitsLength.output); 

                                if [ $? -eq 0 ]; then
                                    whiptail --title "$TITLE" --msgbox "Pomyślnie wygenerowano klucz prywatny." 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Generowanie klucza prywatnego nie powiodło się." 8 $COLUMNS;
                                fi;;
                "Generuj wniosek")
                                getSubj;

                                if [ $? -ne 0 ]; then continue; fi

                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę pliku klucza prywatnego: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS "private/" 2>privKeyFilename.output;
                                if [ $? -ne 0 ]; then continue; fi                                
                                whiptail --title "$TITLE" --passwordbox "Wprowadź hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>privKeypassword.output;
                                if [ $? -ne 0 ]; then continue; fi
                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę dla pliku wniosku:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>requestFilename.output;
                                if [ $? -ne 0 ]; then continue; fi


                                dirLocation=$(cat openssl.cnf | grep "^dir\ =\ " | cut -d " " -f 3);

                                openssl req -new -subj "/C=$(cat subjC.output)/ST=$(cat subjST.output)/L=$(cat subjL.output)/O=$(cat subjO.output)/OU=$(cat subjOU.output)/CN=$(cat subjCN.output)" -key ${dirLocation}/$(cat privKeyFilename.output) -passin pass:$(cat privKeypassword.output) -out ${dirLocation}/$(cat requestFilename.output);

                                if [ $? -eq 0 ]; then 
                                     whiptail --title "$TITLE" --msgbox "Pomyślnie wygenerowano wniosek o certyfikat." 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Generowanie wniosku o certyfikat nie powiodło się." 8 $COLUMNS;
                                fi;;
                "Podpisz wniosek")
                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę pliku wniosku: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>requestFilename.output;
                                if [ $? -ne 0 ]; then continue; fi
                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę pliku certyfikatu: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>certFilename.output;
                                if [ $? -ne 0 ]; then continue; fi
        
                                whiptail --title "$TITLE" --passwordbox "Wprowadź hasło klucza prywatnego CA:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>keyCApassword.output;
                                dirLocation=$(cat openssl.cnf | grep "^dir\ =\ " | cut -d " " -f 3);

                                openssl ca -batch -notext -in ${dirLocation}/$(cat requestFilename.output) -passin pass:$(cat keyCApassword.output) -out ${dirLocation}/$(cat certFilename.output);

                                if [ $? -eq 0 ]; then
                                    whiptail --title "$TITLE" --msgbox "Pomyślnie podpisano wniosek o certyfikat serwera." --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Podpisywanie wniosku o certyfikat serwera nie powiodło sięx." --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS;
                                fi;;
                "Ściągnij hasło")
                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS "private/" 2>privKeyFilename.output;
                                if [ $? -ne 0 ]; then continue; fi
                                whiptail --title "$TITLE" --passwordbox "Wprowadź hasło klucza prytwatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>privKeypassword.output;
                                if [ $? -ne 0 ]; then continue; fi
                                whiptail --title "$TITLE" --inputbox "Wprowadź nazwę dla nowego klucza bez hasła:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>privKeyWithoutPasswordFilename.output;
                                if [ $? -ne 0 ]; then continue; fi
                                dirLocation=$(cat openssl.cnf | grep "^dir\ =\ " | cut -d " " -f 3);

                                openssl rsa -in ${dirLocation}/$(cat privKeyFilename.output) -passin pass:$(cat privKeypassword.output) -out ${dirLocation}/$(cat privKeyWithoutPasswordFilename.output);

                                if [ $? -eq 0 ]; then
                                    whiptail --title "$TITLE" --msgbox "Pomyślnie ściągnieto hasło z klucza prywatnego." 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Sciągnie hasła nia powiodło się." 8 $COLUMNS;
                                fi;;
                "Unieważnij certyfikat")
                                whiptail --title "$TITLE" --inputbox "Podaj nazwę pliku certyfikatu: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>certFileName.output;
                                if [ $? -eq 1 ]; then continue; fi

                                dirLocation=$(cat openssl.cnf | grep "^dir\ =\ " | cut -d " " -f 3);

                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza CA: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>keyCApassword.output;
                                if [ $? -ne 0 ]; then continue; fi

                                openssl ca -revoke ${dirLocation}/$(cat certFileName.output) -passin pass:$(cat keyCApassword.output);

                                if [ $? -eq 0 ]; then
                                    whiptail --title "$TITLE" --msgbox "Unieważnianie certyfikatu powiodło się." 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Unieważnianie certyfikatu nie powiodło się." 8 $COLUMNS;
                                fi;;
                "Generuj CRL")
                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza CA: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>keyCApassword.output;
                                if [ $? -ne 0 ]; then continue; fi

                                crlName=$(cat openssl.cnf | grep '^crl\ =\ ' | cut -d " " -f 3);

                                openssl ca -gencrl -passin pass:$(cat keyCApassword.output) -out $crlName;

                                 if [ $? -eq 0 ]; then
                                    whiptail --title "$TITLE" --msgbox "Pomyślnie wygenerowano listę CRL." 8 $COLUMNS;
                                else
                                    whiptail --title "$TITLE" --msgbox "Generowanie listy CRL nie powiodło się." 8 $COLUMNS;
                                fi;;
                "Sprawdź certyfikat")

                                while [ true ]; do 

                                    whiptail --title "$TITLE" --menu "Aby rozpocząć wybierz jedną z opcji:" --cancel-button "Wróć" $LINES $COLUMNS $(expr $LINES - 12) \
                                            "Termin" "Sprawdź datę ważności certyfikatu" \
                                            "Unieważnienie" "Sprawdź czy certyfikat nie został unieważniony" \
                                            "Wróć" "Powrót do menu głównego" 2> checkMenu.output;

                                    checkOption=$(cat checkMenu.output);
                                    rm checkMenu.option;
                                    dirLocation=$(cat openssl.cnf | grep "^dir\ =\ " | cut -d " " -f 3);
                                    crlLocation=$(cat openssl.cnf | grep "^crl\ =\ " | cut -d " " -f 3);  

                                    case $checkOption in

                                        "Termin") 
                                                    whiptail --title "$TITLE" --inputbox "Wprowadź nazwę certyfikatu: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>certFilename.output;
                                                    if [ $? -ne 0 ]; then continue; fi  

                                                    nAfterDate=$(openssl x509 -noout -text -in ${dirLocation}/$(cat certFilename.output) | grep 'Not After' | cut -d ":" -f 2- | cut -d " " -f 2-);
                                                    unixTimestampNAfterDate=`date +"%s" -d "$nAfterDate"`;
                                                    unixTimestampCurrent=`date +"%s"`;

                                                    if [ $unixTimestampNAfterDate -gt $unixTimestampCurrent ]; then 
                                                       whiptail --title "$TITLE" --msgbox "Certyfikat jest ważny. Do: `date -d "$nAfterDate"`" 8 $COLUMNS;
                                                    else
                                                       whiptail --title "$TITLE" --msgbox "Certyfikat jest już nieważny." 8 $COLUMNS;
                                                    fi;;
                                        "Unieważnienie")
                                                    whiptail --title "$TITLE" --inputbox "Wprowadź nazwę certyfikatu: " --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>certFilename.output;
                                                    if [ $? -ne 0 ]; then continue; fi  
                                                    serial=$(openssl x509 -in ${dirLocation}/$(cat certFilename.output) -noout -serial | cut -d "=" -f 2);
                                                    
                                                    openssl crl -text -in ${crlLocation} | grep "Serial Number: ${serial}" > /dev/null;

                                                    if [ $? -eq 0 ]; then
                                                        whiptail --title "$TITLE" --msgbox "Certyfikat został unieważniony" 8 $COLUMNS;
                                                    else
                                                        whiptail --title "$TITLE" --msgbox "Certyfikat nie został unieważniony" 8 $COLUMNS;
                                                    fi;;
                                        *) rm *.output;
                                            break;;
                                    esac

                                done;;
                "Konwersje")

                            while [ true ]; do

                                whiptail --title "$TITLE" --menu "Aby rozpocząć wybierz jedną z opcji:" --cancel-button "Wróć" $LINES $COLUMNS $(expr $LINES - 12) \
                                            "DER (cert)" "PEM (TXT, Base64) -> DER (Binarny)" \
                                            "PEM (cert)" "DER (Binarny) -> PEM (TXT, Base64)" \
                                            "DER (key)" "PEM (TXT, Base64) -> DER (Binarny)" \
                                            "PEM (key)" "DER (Binarny) -> PEM (TXT, Base64)" \
                                            "PKCS#12" "PEM (cert+key) (TXT, Base64) -> PKCS#12 (Binarny)" \
                                            "PEM (cert, PKCS#12)" "PKCS#12 (Binarny) -> PEM (cert, TXT, Base64)" \
                                            "PEM (key, PKCS#12)" "PKCS#12 (Binarny) -> PEM (key, TXT, Base64)" \
                                            "Wróć" "Powrót do menu głównego" 2> convMenu.output;

                                convOption=$(cat convMenu.output);

                                rm convMenu.output;

                                case $convOption in

                                    "DER (cert)")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wejściowego w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> derCertInputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wyjściowego w formacie DER:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> derCertOutputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                inputFile=$(cat derCertInputFilename.output);
                                                outputFile=$(cat derCertOutputFilename.output);

                                                openssl x509 -in ${inputFile} -out ${outputFile} -outform DER;

                                                if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                    "PEM (cert)")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wejściowego w formacie DER:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> pemCertInputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wyjściowego w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> pemCertOutputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                inputFile=$(cat pemCertInputFilename.output);
                                                outputFile=$(cat pemCertOutputFilename.output);

                                                openssl x509 -in ${inputFile} -inform DER -out ${outputFile} -outform PEM;

                                                if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                    "DER (key)")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wejściowego w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> derCertInputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> privKeypassword.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wyjściowego w formacie DER:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> derCertOutputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                inputFile=$(cat derCertInputFilename.output);
                                                outputFile=$(cat derCertOutputFilename.output);

                                                openssl rsa -in ${inputFile} -inform PEM -passin pass:$(cat privKeypassword.output) -out ${outputFile} -outform DER -passout pass:$(cat privKeypassword.output)

                                                if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                     "PEM (key)")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wejściowego w formacie DER:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> derCertInputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi
                                                
                                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> privKeypassword.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do plik wyjściowego w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> derCertOutputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                inputFile=$(cat derCertInputFilename.output);
                                                outputFile=$(cat derCertOutputFilename.output);

                                                openssl rsa -in ${inputFile} -inform DER -out ${outputFile} -outform PEM

                                                if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                    "PKCS#12")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku klucza prywatnego w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> pkcsInputKeyFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi
                                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> privKeypassword.output;
                                                if [ $? -ne 0 ]; then continue; fi 
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku certyfikatu w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>pkcsInputCertFilename.output
                                                if [ $? -ne 0 ]; then continue; fi
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku wyjściowego w formacie PKCS#12 (.p12):" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>pkcsOutputFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                keyFilename=$(cat pkcsInputKeyFilename.output);
                                                certFilename=$(cat pkcsInputCertFilename.output);
                                                pkcsFilename=$(cat pkcsOutputFilename.output);

                                                openssl pkcs12 -export -out ${pkcsFilename} -passout pass:$(cat privKeypassword.output) -inkey ${keyFilename} -passin pass:$(cat privKeypassword.output) -in ${certFilename};

                                                 if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                    "PEM (cert, PKCS#12)")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku certyfikatu w formacie PKCS#12:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> pkcsInputCertFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi

                                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> privKeypassword.output;
                                                if [ $? -ne 0 ]; then continue; fi 

                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku certyfikatu w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>pkcsOutputCertFilename.output
                                                if [ $? -ne 0 ]; then continue; fi

                                                pkcsFilename=$(cat pkcsInputCertFilename.output);
                                                pemOutputFilename=$(cat pkcsOutputCertFilename.output);

                                                openssl pkcs12 -in ${pkcsFilename} -passin pass:$(cat privKeypassword.output) -out ${pemOutputFilename} -clcerts -nokeys;

                                                if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                    "PEM (key, PKCS#12)")
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku certyfikatu w formacie PKCS#12:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> pkcsInputCertFilename.output;
                                                if [ $? -ne 0 ]; then continue; fi
                                                whiptail --title "$TITLE" --inputbox "Podaj ścieżkę do pliku klucza prywatnego w formacie PEM:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2>pkcsOutputCertFilename.output
                                                if [ $? -ne 0 ]; then continue; fi
                                                whiptail --title "$TITLE" --passwordbox "Podaj hasło klucza prywatnego:" --ok-button "Dalej" --cancel-button "Anuluj" 8 $COLUMNS 2> privKeypassword.output;
                                                if [ $? -ne 0 ]; then continue; fi 

                                                pkcsFilename=$(cat pkcsInputCertFilename.output);
                                                pemOutputFilename=$(cat pkcsOutputCertFilename.output);

                                                openssl pkcs12 -in ${pkcsFilename} -passin pass:$(cat privKeypassword.output) -out ${pemOutputFilename} -passout pass:$(cat privKeypassword.output) -nocerts;

                                                if [ $? -eq 0 ]; then
                                                    whiptail --title  "$TITLE" --msgbox "Konwersja powiodła się." 8 $COLUMNS;
                                                else
                                                    whiptail --title "$TITLE" --msgbox "Konwersja nie powiodła się." 8 $COLUMNS;
                                                fi;;
                                    *) rm *.output;
                                        break;;
                                esac 

                            done;; 
                "Konfiguruj dostęp")
                                    whiptail --title "$TITLE" --yesno "Dostęp realizowanym będzie za pomocą protokołu HTTP. \
                                    Połączenia HTTP będa obsługiwane przez daemon mini_httpd\nCzy chcesz uruchomić go teraz ?" --yes-button "TAK" --no-button "NIE" 8 $COLUMNS;
                                    if [ $? -eq 0 ]; then

                                        if [ ! $(which mini_httpd) ]; then 
                                            apt update
                                            apt-get install -y mini-httpd;
                                            sleep 5;
                                            cp mini-httpd /etc/init.d/
                                            systemctl daemon-reload
                                            /etc/init.d/mini-httpd start;
                                            /etc/init.d/mini-httpd stop;
                                        fi

                                        if [ ! $(pidof mini_httpd) ]; then
                                            systemctl daemon-reload
                                            /etc/init.d/mini-httpd start;
                                        else 
                                            whiptail --title "$TITLE" --msgbox "Proces mini_httpd został już uruchomiony." 8 $COLUMNS;
                                        fi

                                    fi;;
                "Wyjście") poweroff;;
                *) rm *.output;
                    break;;
            esac
        done
    else
        whiptail --title "$TITLE" --msgbox "Nie znaleziono pakietu OpenSSL" 8 $COLUMNS;
    fi
else
    whiptail --title "$TITLE" --msgbox "Musisz uruchomić skrypt jako root" 8 $COLUMNS;
    exit 1;
fi
