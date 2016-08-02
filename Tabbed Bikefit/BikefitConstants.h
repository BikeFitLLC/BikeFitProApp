#define S3_IMAGE_URL_FORMAT @"http://s3-us-west-2.amazonaws.com/%@/%@"
#define FILESYSTEM_IMAGE_FILENAME_FORMAT @"/%@/%@"

#define USER_DEFAULTS_AWS_ACCESS_KEY_KEY @"AccessKey"
#define USER_DEFAULTS_AWS_SECRET_KEY_KEY @"SecretKey"
#define USER_DEFAULTS_AWS_EXPIRATION @"Expiration"
#define USER_DEFAULTS_FITTERID_KEY @"FitterID"
#define USER_DEFAULTS_USERNAME_KEY @"username"
#define USER_DEFAULTS_FITTERNAME_KEY @"fittername"
#define USER_DEFAULTS_PASSWORD_KEY @"password"
///#define USER_DEFAULTS_FITID_KEY @"FitID"
#define USER_DEFAULTS_ACCOUNT_ACTIVE_KEY @"accountactive"
#define USER_DEFAULTS_IS_TRIAL_ACCOUNT @"istrialaccount"

#define LOCAL_FILE_ID @"localfile"
#define LOCAL_FITTER_ID @"localfitter"

#define AWS_FIT_ATTRIBUTE_FITTERID @"FitterID"
#define AWS_FIT_ATTRIBUTE_FITID @"FitID"
#define AWS_FIT_ATTRIBUTE_FIRSTNAME @"FirstName"
#define AWS_FIT_ATTRIBUTE_LASTNAME @"LastName"
#define AWS_FIT_ATTRIBUTE_EMAIL @"Email"
#define AWS_FIT_ATTRIBUTE_LASTUPDATED @"DateUpdated"
#define AWS_FIT_ATTRIBUTE_URL @"FitUrl"
#define AWS_FIT_ATTRIBUTE_HIDDEN @"Hidden"
#define AWS_FIT_ATTRIBUTE_BIKE_TYPE @"BikeType"

#define FIT_ATTRIBUTE_FROMFILESYSTEM @"FromFileSystem"

#define AWS_FITTER_ATTRIBUTE_FITTERKEY @"FitterKey"
#define AWS_FITTER_ATTRIBUTE_FITTERID @"FitterID"

#define AWS_FIT_TABLE_NAME_FORMAT @"%@-fits"

#define S3_BUCKET @"8190ba10-d310-11e3-9c1a-0800200c9a66"

//#define TVM_HOSTNAME @"http://tvm-env-test.elasticbeanstalk.com"
#define TVM_HOSTNAME @"https://tvm.velopezdigital.com/"
//#define TVM_HOSTNAME @"http://127.0.0.1:8000"
#define TVM_GET_CREDENTIALS_OAUTH_PATH @"/?Email=%@&Name=%@&Token=%@"
#define TVM_GET_CREDENTIALS_PATH @"/getToken?Email=%@&Password=%@"
#define TVM_CREATE_ACCOUNT_PATH @"/createAccount?Email=%@&Password=%@&Name=%@"
#define TVM_IS_AMAZON_PATH @"/isAmazonAccount?Email=%@"

//#define TOKEN_VENDING_MACHINE_URL_FORMAT @"https://tvm.velopezdigital.com/?Email=%@&Name=%@&Token=%@"
//#define TOKEN_VENDING_MACHINE_URL_FORMAT @"http://127.0.0.1:8000/?Email=%@&Name=%@&Token=%@"
//#define TOKEN_VENDING_MACHINE_URL_FORMAT @"http://tvm-env-test.elasticbeanstalk.com/?Email=%@&Name=%@&Token=%@"

