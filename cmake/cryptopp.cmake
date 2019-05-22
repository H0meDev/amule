IF (NOT CRYPTOPP_INCLUDE_PREFIX)
	FIND_PATH (CRYPTOPP_INCLUDE_PREFIX_TMP
		NAMES cryptlib.h
		PATHS ENV
	)

	IF (CRYPTOPP_INCLUDE_PREFIX_TMP)
		SET (CRYPTOPP_INCLUDE_PREFIX "" CACHE PATH "cryptopp include prefix")
	ELSE (CRYPTOPP_INCLUDE_PREFIX_TMP)
		FIND_PATH (CRYPTOPP_INCLUDE_PREFIX_TMP
			NAMES cryptopp/cryptlib.h
			PATHS ENV
		)

		IF (CRYPTOPP_INCLUDE_PREFIX_TMP)
			SET (CRYPTOPP_INCLUDE_PREFIX "cryptopp" CACHE PATH "cryptopp include prefix")
		ELSE (CRYPTOPP_INCLUDE_PREFIX_TMP)
			FIND_PATH (CRYPTOPP_INCLUDE_PREFIX_TMP
				NAMES crypto++/cryptlib.h
				PATHS ENV
			)

			IF (CRYPTOPP_INCLUDE_PREFIX_TMP)
				SET (CRYPTOPP_INCLUDE_PREFIX "crypto++" CACHE PATH "cryptopp include prefix")
			ELSE (CRYPTOPP_INCLUDE_PREFIX_TMP)
				FOREACH (SEARCH_PATH ${CRYTOPP_HEADER_PATH})
					FIND_PATH (CRYPTOPP_INCLUDE_PREFIX_TMP
						NAMES cryptlib.h
						PATHS ${SEARCH_PATH}
					)

					IF (NOT CRYPTOPP_INCLUDE_PREFIX)
						MESSAGE (FATAL_ERROR "crypto++ headers not found")
					ENDIF (NOT CRYPTOPP_INCLUDE_PREFIX)
				ENDFOREACH (SEARCH_PATH ${CRYTOPP_SEARCH_PATH})
			ENDIF (CRYPTOPP_INCLUDE_PREFIX_TMP)
		ENDIF (CRYPTOPP_INCLUDE_PREFIX_TMP)
	ENDIF (CRYPTOPP_INCLUDE_PREFIX_TMP)
ENDIF (NOT CRYPTOPP_INCLUDE_PREFIX)

MESSAGE (STATUS "Found cryptlib.h in ${CRYPTOPP_INCLUDE_PREFIX}")

FIND_LIBRARY (CRYPTOLIB 
	NAMES crypto++ cryptlib
)

IF (NOT CRYPTOLIB)
	FIND_LIBRARY (CRYPTOLIB
		NAMES cryptopp cryptlib
		PATHS ${CRYTOPP_LIB_SEARCH_PATH}
	)
ENDIF (NOT CRYPTOLIB)

MESSAGE (STATUS "Found libcrypto++ in ${CRYPTOLIB}")

FIND_FILE (CRYPTOPP_CONFIG_FILE
	NAME ${CRYPTOPP_INCLUDE_PREFIX}/config.h
	PATHS ENV
)

IF (NOT CRYPTOPP_CONFIG_FILE)
	FIND_FILE (CRYPTOPP_CONFIG_FILE
		NAME config.h
		PATHS ${CRYTOPP_HEADER_PATH}
	)
ENDIF (NOT CRYPTOPP_CONFIG_FILE)

FILE (STRINGS ${CRYPTOPP_CONFIG_FILE} CRYPTTEST_OUTPUT REGEX "define CRYPTOPP_VERSION")
STRING (REGEX REPLACE "#define CRYPTOPP_VERSION " "" CRYPTOPP_VERSION "${CRYPTTEST_OUTPUT}")
STRING (REGEX REPLACE "([0-9])([0-9])([0-9])" "\\1.\\2.\\3" CRYPTOPP_VERSION "${CRYPTOPP_VERSION}")


IF (${CRYPTOPP_VERSION} VERSION_LESS ${MIN_CRYPTOPP_VERSION})
	MESSAGE (FATAL_ERROR "crypto++ version ${CRYPTOPP_VERSION} is too old")
ELSE (${CRYPTOPP_VERSION} VERSION_LESS ${MIN_CRYPTOPP_VERSION})
	MESSAGE (STATUS "crypto++ version ${CRYPTOPP_VERSION} -- OK")

	IF (${CRYPTOPP_VERSION} VERSION_GREATER 5.5.0)
		MESSAGE (STATUS "Enabling usage of weak algo's for crypto")
		SET (__WEAK_CRYPTO__ TRUE)
	ENDIF (${CRYPTOPP_VERSION} VERSION_GREATER 5.5.0)
ENDIF (${CRYPTOPP_VERSION} VERSION_LESS ${MIN_CRYPTOPP_VERSION})
