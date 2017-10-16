/*
 * serial.c
 *
 *  Created on: Apr 21, 2017
 *      Author: bdsound
 */

#include "serial.h"
#include <sys/ioctl.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>             //Used for UART
#include <fcntl.h>              //Used for UART
#include <termios.h>        //Used for UART
#include <time.h>
#include <string.h>
#include <poll.h>
#include "utility.h"
//#include "commands.h"


int serial_init(const char * dev)
{
	int res;
	// Open
    //  O_NDELAY / O_NONBLOCK (same function) - Enables nonblocking mode. When set read requests on the file can return immediately with a failure status
    //                                          if there is no input immediately available (instead of blocking). Likewise, write requests can also return
    //                                          immediately with a failure status if the output can't be written immediately.
    //
    //  O_NOCTTY - When set and path identifies a terminal device, open() shall not cause the terminal device to become the controlling terminal for the process.
	res = open(dev,O_RDWR | O_NOCTTY | O_NONBLOCK);

	if(res<0)
	{
		//BERROR << "[serial] Opening " << dev << " error : " << res;
		return -1;
	}
	//BINFO << "[serial] Opening " << dev << " success";
	//CONFIGURE THE UART
	//The flags (defined in termios.h - see http://pubs.opengroup.org/onlinepubs/007908799/xsh/termios.h.html):
	//  Baud rate:- B1200, B2400, B4800, B9600, B19200, B38400, B57600, B115200, B230400, B460800, B500000, B576000, B921600, B1000000, B1152000, B1500000, B2000000, B2500000, B3000000, B3500000, B4000000
	//  CSIZE:- CS5, CS6, CS7, CS8
	//  CLOCAL - Ignore modem status lines
	//  CREAD - Enable receiver
	//  IGNPAR = Ignore characters with parity errors
	//  ICRNL - Map CR to NL on input
	//  PARENB - Parity enable
	//  PARODD - Odd parity (else even)
	struct termios cfg;

	//get existing configuration setup
	tcgetattr(res, &cfg);

	//fcntl(deviceFD, F_SETFL, FNDELAY);
	fcntl(res, F_SETFL, 0);

	////set both incoming and outgoing baud rates...
//	cfsetispeed(&cfg, B1000000);//B115200);
//	cfsetospeed(&cfg, B1000000);//B115200);
	cfsetispeed(&cfg, B115200);
	cfsetospeed(&cfg, B115200);

	cfg.c_cflag |= (CLOCAL | CREAD);

	////8N1 (8 data bits, No parity, 1 stop bit)
	cfg.c_cflag &= ~PARENB;
	cfg.c_cflag &= ~CSTOPB;
	cfg.c_cflag &= ~CSIZE;
	cfg.c_cflag |= CS8;

	//cfg.c_cflag &= ~CRTSCTS;  //~CNEW_RTSCTS; //disable hardware flow control

	//use RAW unbuffered data mode (eg, not canonical mode)
	cfg.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG | IGNBRK);

    //cfg.c_iflag &= ~INPCK; // disable parity checkBD_SYSTEM_STATUS_DEAD
	cfg.c_iflag &= ~INLCR;
	cfg.c_iflag &= ~ICRNL;
	cfg.c_iflag &= ~IGNBRK;
	cfg.c_iflag &= ~IGNCR;
	cfg.c_iflag &= ~IUCLC;
	cfg.c_iflag &= ~IXANY;
	cfg.c_iflag &= ~IXOFF;
	cfg.c_iflag &= ~IXON;
	//cfg.c_iflag &= ~(IGNPAR | IXON | IXOFF | IXANY);

	//raw (unprocessed) output mode
	cfg.c_oflag &= ~OPOST;

	tcsetattr(res, TCSANOW, &cfg);

	return res;

}

void serial_deinit(int fid)
{
	close(fid);
}

int serial_write(int fid, uint8_t * buf, int len)
{
	return write(fid, buf, len);
}

int serial_read(int fid, uint8_t * buf, int maxLen)
{
	struct pollfd fds;
	fds.fd = fid;
	fds.events = POLLIN ;
	int pollrc = poll(&fds, 1, 10);
	if (pollrc < 0)
	{
	    perror("Error on serial port poll\n");
	    return 0;
	}

	if( fds.revents & POLLIN )
	{
		  return read( fid, buf, maxLen ); /* there was data to read */
	}
	return 0;
}


