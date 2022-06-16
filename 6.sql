IF EXISTS (
    SELECT 1 FROM sys.configurations 
    WHERE NAME = 'Database Mail XPs' AND VALUE = 0)
BEGIN
  PRINT 'Enabling Database Mail XPs'
  EXEC sp_configure 'show advanced options', 1;  
  RECONFIGURE
  EXEC sp_configure 'Database Mail XPs', 1;  
  RECONFIGURE  
END

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysmail_account WHERE [name] = 'DBA Email Account')
	BEGIN
		EXECUTE msdb.dbo.sysmail_add_account_sp
		@account_name = 'DBA Email Account',
		@description = 'DB account for DBAs and SQL Agent',
		@email_address = 'jose.escudero@udla.edu.ec',
		@display_name = 'Flicks4U',
		@mailserver_name = 'smtp.sendgrid.net',
		@mailserver_type = 'SMTP',
		@username = 'apikey',
		@password = '<REEMPLAZAR CON SENDGRID API KEY>',
		@port = 587,
		@enable_ssl = 1;
	END
ELSE
	PRINT 'sysmail_account already configured'

-- Create a database mail profile (Profile must be called AzureManagedInstance_dbmail_profile)
IF NOT EXISTS (SELECT 1 FROM msdb..sysmail_profile WHERE name = 'DBA_Email_Profile')
	BEGIN
		EXECUTE msdb.dbo.sysmail_add_profile_sp
		@profile_name = 'DBA_Email_Profile',
		@description = 'Main profile for sending database mail';
		-- Associate account with profile
		EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
		@profile_name = 'DBA_Email_Profile',
		@account_name = 'DBA Email Account',
		@sequence_number = 1 ;
	END
ELSE
	PRINT 'DBMail profile already configured'


CREATE TRIGGER NotificacionContratacion
	ON RecursosHumanos.Empleado
	FOR INSERT
	AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @email nvarchar(50)
		SET @email = (SELECT INSERTED.Correo FROM INSERTED)
		DECLARE @body NVARCHAR(80)
		SET @body = CONCAT('Nuevo empleado contratado. Su correo es: ', @email)
		EXEC msdb.dbo.sp_send_dbmail  @profile_name = 'DBA_Email_Profile',
		  @recipients = 'joseignacioescudero@gmail.com', 
		  @subject = 'Nuevo empleado contratado!', 
		  @body = @body
	END
RETURN