/*  
 *	RFconf.h
 *	RESTframework
 *
 *	Created by Ivan Vasić on 9/4/11.
 *	Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework.
 *
 *	RESTframework is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU Lesser General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	RESTframework is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU Lesser General Public License for more details.
 *	
 *	You should have received a copy of the GNU Lesser General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef RESTframework_RFconf_h
#define RESTframework_RFconf_h

#define RFLog(fmt, ...) NSLog((@"RF: " fmt), ##__VA_ARGS__);
#define RFLogWarning(fmt, ...) NSLog((@"RF warning: " fmt), ##__VA_ARGS__);
#define RFLogError(fmt, ...) NSLog((@"RF error: " fmt), ##__VA_ARGS__);

#endif
