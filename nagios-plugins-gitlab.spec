Name:		nagios-plugins-gitlab
Version:	1.0
Release:	1%{?dist}
Summary:	Gitlab plugin for Icinga/Nagios

Group:		Applications/System
License:	GPLv3
URL:		https://github.com/scrat14/check_gitlab
Source0:	check_gitlab-%{version}.tar.gz
BuildRoot:	%{_tmppath}/check_gitlab-%{version}-%{release}-root

%description
This plugin for Icinga/Nagios is used to monitor status of Gitlab
services.

BuildRequires: sudo
BuildRequires: nagios-plugins
Requires: sudo

%prep
%setup -q -n check_gitlab-%{version}

%build
%configure --prefix=%{_libdir}/nagios/plugins \
	   --with-nagios-user=nagios \
	   --with-nagios-group=nagios

make all


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT INSTALL_OPTS=""

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(0755,nagios,nagios)
%{_libdir}/nagios/plugins/check_gitlab
%attr(0440,root,root) %{_sysconfdir}/sudoers.d/check_gitlab
%doc README INSTALL NEWS ChangeLog LICENSE



%changelog
* Tue Oct 27 2015 Rene Koch <rkoch@rk-it.at> 1.0-2
- Fixed permissions for sudoers file.

* Wed Apr 29 2015 Rene Koch <rkoch@rk-it.at> 1.0-1
- Initial build.

