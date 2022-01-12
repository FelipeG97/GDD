--DECLARAR VARIABLES

DECLARE @TRANS VARCHAR(20),
        @NEWURL VARCHAR(MAX),
	    @OLDURL VARCHAR(MAX),
	    @OLDJSON VARCHAR(MAX),
	    @NEWJSON VARCHAR(MAX),
		@PARAMETRO_ACTUALIZADO VARCHAR(MAX),
		@CREA_URL BIT,
		@MODIFICAR_URL BIT,
		@BORRA_URL BIT


SET @OLDURL = 'TEST40000'
SET @NEWURL = 'TEST_PRUEBA_3'
SET @CREA_URL= 0
SET @MODIFICAR_URL= 0
SET @BORRA_URL= 0

-- CHECK VISUAL = 0, CAMBIAR FECHA EVENTO COLOCAR EN 1
DECLARE @PROCESO INT = 0

--- ***************************************************************************** ---
IF @Proceso = 1
BEGIN
		BEGIN TRY
			BEGIN TRAN @TRANS

				SELECT @OLDJSON  = valor FROM Parametro WHERE Parametro='WEB:Redireccion'

				IF ISJSON(@OLDJSON) = 1
				BEGIN

					IF OBJECT_ID('tempdb..#NEWJSON') IS NOT NULL 
					DROP TABLE #NEWJSON
					CREATE TABLE #NEWJSON(
						OrigenUrl NVARCHAR(max),
						DestinoUrl NVARCHAR(max),
						HttpStatus NVARCHAR(3)
					)

					INSERT INTO #NEWJSON
					SELECT OrigenUrl, DestinoUrl, HttpStatus FROM OPENJSON(@OLDJSON )
					WITH (
						OrigenUrl NVARCHAR(max) '$.OrigenUrl',
						DestinoUrl NVARCHAR(max) '$.DestinoUrl',
						HttpStatus NVARCHAR(3) '$.HttpStatus'
					  );

					if NOT EXISTS (SELECT * FROM #NEWJSON WHERE OrigenUrl='evento/'+ @OLDURL) AND @CREA_URL=1 AND @MODIFICAR_URL=0 AND @BORRA_URL=0
						BEGIN

								INSERT INTO #NEWJSON(OrigenUrl,DestinoUrl,HttpStatus) 
								values('evento/'+ @OLDURL,'https://www.puntoticket.com/evento/'+@NEWURL,301)

								SELECT @NEWJSON = (SELECT * FROM #NEWJSON FOR JSON AUTO)

								UPDATE Parametro SET Valor= @NEWJSON WHERE Parametro='WEB:Redireccion'

								SELECT @OLDJSON AS OLDJSON, @NEWJSON AS NEWJSON

								SELECT @PARAMETRO_ACTUALIZADO = Valor FROM Parametro WHERE Parametro='WEB:Redireccion'

								SELECT OrigenUrl, DestinoUrl, HttpStatus FROM OPENJSON(@PARAMETRO_ACTUALIZADO)
								WITH (
									OrigenUrl NVARCHAR(max) '$.OrigenUrl',
									DestinoUrl NVARCHAR(max) '$.DestinoUrl',
									HttpStatus NVARCHAR(3) '$.HttpStatus'
								  );
								SELECT 'REGISTRO PROCESADO OK'
						END
						ELSE IF EXISTS (SELECT * FROM #NEWJSON WHERE OrigenUrl='evento/'+ @OLDURL) AND @MODIFICAR_URL=1 AND @CREA_URL=0 AND @BORRA_URL=0
						BEGIN
								UPDATE #NEWJSON SET DestinoUrl= 'https://www.puntoticket.com/evento/'+@NEWURL WHERE OrigenUrl='evento/'+ @OLDURL

								SELECT @NEWJSON = (SELECT * FROM #NEWJSON FOR JSON AUTO)

								UPDATE Parametro SET Valor= @NEWJSON WHERE Parametro='WEB:Redireccion'

								SELECT @OLDJSON AS OLDJSON, @NEWJSON AS NEWJSON

								SELECT @PARAMETRO_ACTUALIZADO = Valor FROM Parametro WHERE Parametro='WEB:Redireccion'

								SELECT OrigenUrl, DestinoUrl, HttpStatus FROM OPENJSON(@PARAMETRO_ACTUALIZADO)
								WITH (
									OrigenUrl NVARCHAR(max) '$.OrigenUrl',
									DestinoUrl NVARCHAR(max) '$.DestinoUrl',
									HttpStatus NVARCHAR(3) '$.HttpStatus'
								  );
								  SELECT 'REGISTRO PROCESADO OK'
					  END
					  ELSE IF EXISTS (SELECT * FROM #NEWJSON WHERE OrigenUrl='evento/'+ @OLDURL) AND @BORRA_URL=1 AND @MODIFICAR_URL=0 AND @CREA_URL=0
						BEGIN
								DELETE FROM #NEWJSON WHERE OrigenUrl='evento/'+ @OLDURL

								SELECT @NEWJSON = (SELECT * FROM #NEWJSON FOR JSON AUTO)

								UPDATE Parametro SET Valor= @NEWJSON WHERE Parametro='WEB:Redireccion'

								SELECT @OLDJSON AS OLDJSON, @NEWJSON AS NEWJSON

								SELECT @PARAMETRO_ACTUALIZADO = Valor FROM Parametro WHERE Parametro='WEB:Redireccion'

								SELECT OrigenUrl, DestinoUrl, HttpStatus FROM OPENJSON(@PARAMETRO_ACTUALIZADO)
								WITH (
									OrigenUrl NVARCHAR(max) '$.OrigenUrl',
									DestinoUrl NVARCHAR(max) '$.DestinoUrl',
									HttpStatus NVARCHAR(3) '$.HttpStatus'
								  );
								  SELECT 'REGISTRO PROCESADO OK'
					  END
					ELSE 
					  BEGIN
					  SELECT 'FAVOR REVISAR, YA QUE, QUERY NO PERMITE CREAR, MODIFICAR Y BORRAR AL MISMO TIEMPO ', 
					  'O REGISTRO ' +@OLDURL+ ' YA EXISTE AL CREAR O NO EXISTE AL MODIFICAR/BORRAR'
					  END
				END
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			PRINT 'ROLLBACK INICIADO'
			ROLLBACK TRAN @TRANS
			SELECT 'ERROR, ROLLBACK EJECUTADO' Result, ERROR_MESSAGE(), ERROR_LINE()
		END CATCH
END
ELSE 
BEGIN
			
		SELECT @OLDJSON  = valor FROM Parametro WHERE Parametro='WEB:Redireccion'

		IF ISJSON(@OLDJSON) = 1
		BEGIN

		    SELECT @OLDJSON AS OLDJSON

			SELECT OrigenUrl, DestinoUrl, HttpStatus FROM OPENJSON(@OLDJSON )
			 WITH (
				    OrigenUrl NVARCHAR(max) '$.OrigenUrl',
				    DestinoUrl NVARCHAR(max) '$.DestinoUrl',
				    HttpStatus NVARCHAR(3) '$.HttpStatus'
				   );

         END
END