#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

static bool g_IsContinue = true;

void signal_handler( int value, siginfo_t* info, void * context ){
    printf( "signal_handler: value=%d\n", value );
    
    if ( SIGTERM == value ){
        g_IsContinue = false;
    }
}

int main( int argc, char* argv[] ){
    int result = 0;
    if ( argc <= 1 ){
        struct sigaction new_action;
        memset( &new_action, 0, sizeof( new_action ) );
        new_action.sa_sigaction = signal_handler;
        new_action.sa_mask = 0;
        new_action.sa_flags = SA_SIGINFO | SA_NOCLDWAIT;
        sigaction( SIGINT, &new_action, NULL );
        
        do{
            sleep( 1 );
        }while ( g_IsContinue );
    }else{
        result = strtol( argv[ 1 ], NULL, 0 );
    }
    return result;
}
