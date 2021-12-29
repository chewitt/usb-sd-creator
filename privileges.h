////////////////////////////////////////////////////////////////////////////////
//      This file is part of LibreELEC - http://www.libreelec.tv
//      Copyright (C) 2016 Team LibreELEC
//
//  LibreELEC is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  LibreELEC is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////

#ifndef PRIVILEGES_H
#define PRIVILEGES_H

class Privileges {
public:
    Privileges() {}
    void SetRoot() {}
    void SetUser() {}
    void SetRealUser() {}
    void Whoami() {}
    void SaveUserEnv(pid_t) {}
    QString GetUserEnvDbusSession()
    {
        return QString();
    }
    QString GetUserEnvLogname()
    {
        return QString();
    }
};

#endif // PRIVILEGES_H
