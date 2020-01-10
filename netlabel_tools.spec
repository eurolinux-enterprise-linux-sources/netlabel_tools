Summary: Tools to manage the Linux NetLabel subsystem
Name: netlabel_tools
Version: 0.20
Release: 5%{?dist}
License: GPLv2
Group: System Environment/Daemons
URL: http://netlabel.sf.net/
Source0: http://downloads.sourceforge.net/netlabel/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}
Requires: kernel >= 2.6.19
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
BuildRequires: kernel-headers >= 2.6.19
BuildRequires: libnl-devel
BuildRequires: doxygen
BuildRequires: systemd

Patch01: netlabelctl-addr_parse_fix.patch
Patch02: libnetlabel-nla_put_nested_fix.patch
Patch03: libnetlabel-message_size.patch

%description
NetLabel is a kernel subsystem which implements explicit packet labeling
protocols such as CIPSO for Linux.  Packet labeling is used in secure networks
to mark packets with the security attributes of the data they contain.  This
package provides the necessary user space tools to query and configure the
kernel subsystem.

%prep
%setup -q

%patch01 -p1
%patch02 -p1
%patch03 -p1

%build
./configure --prefix="%{_prefix}" --libdir="%{_libdir}" --enable-systemd
CFLAGS="%{optflags}" make V=1 %{?_smp_mflags}

%install
rm -rf "%{buildroot}"
mkdir -p "%{buildroot}/etc"
mkdir -p "%{buildroot}/%{_sbindir}"
mkdir -p "%{buildroot}/%{_unitdir}"
mkdir -p "%{buildroot}/%{_mandir}"
make V=1 DESTDIR="%{buildroot}" install

%preun
%systemd_preun netlabel.service

%postun
%systemd_postun

%post
%systemd_post netlabel.service

%files
%defattr(-,root,root)
%doc README CHANGELOG LICENSE
%attr(0644,root,root) %{_mandir}/man8/*
%attr(0755,root,root) %{_sbindir}/netlabelctl
%attr(0755,root,root) %{_sbindir}/netlabel-config
%attr(0644,root,root) %{_unitdir}/netlabel.service
%attr(0644,root,root) %config(noreplace) /etc/netlabel.rules

%changelog
* Thu Feb 27 2014 Paul Moore <pmoore@redhat.com> - 0.20-5
- Build with CFLAGS="${optflags}" (RHBZ #1070780)
* Fri Jan 24 2014 Daniel Mach <dmach@redhat.com> - 0.20-4
- Mass rebuild 2014-01-24

* Wed Jan 15 2014 Paul Moore <pmoore@redhat.com> - 0.20-3
- Fix a problem when adding a CIPSO DOI with a large number of translations
- Remove old patches
  Resolves: #1053687

* Fri Dec 27 2013 Daniel Mach <dmach@redhat.com> - 0.20-2
- Mass rebuild 2013-12-27

* Fri Oct 25 2013 Paul Moore <pmoore@redhat.com> - 0.20-1
- Add input validation on network address masks (#1003909)

* Mon Jun 3 2013 Paul Moore <pmoore@redhat.com> - 0.20-0
- Version bump to match latest upstream
- Cleanups in the specfile due to changes in the upstream package

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.19-12
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Fri Jul 20 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.19-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Fri Jan 13 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.19-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.19-9
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Thu Jun 17 2010 Peter Vrabec <pvrabec@redhat.com> - 0.19-8
- fixing return codes (#602291)

* Wed Jun 16 2010 Peter Vrabec <pvrabec@redhat.com> - 0.19-7
- make initscript LSB compliant (#522818)
- show version of netlabelctl and libnetlabel in help (#602577)

* Wed Sep 23 2009 Peter Vrabec <pvrabec@redhat.com> 0.19-6
- make initscript LSB compliant (#522818)

* Wed Sep 23 2009 Peter Vrabec <pvrabec@redhat.com> 0.19-5
- increase rel. number

* Wed Sep 23 2009 Peter Vrabec <pvrabec@redhat.com> 0.19-4
- fix license tag in spec (#524310)

* Sat Jul 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.19-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Feb 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.19-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Thu Jan 08 2009 Peter Vrabec <pvrabec@redhat.com> - 0.19-1
- upgrade (#478903)

* Mon Oct 27 2008 Peter Vrabec <pvrabec@redhat.com> - 0.18-1
- upgrade (#439833)

* Mon Aug 11 2008 Tom "spot" Callaway <tcallawa@redhat.com> - 0.17-8
- fix license tag

* Mon Feb  11 2008 Steve Conklin <sconklin@redhat.com> - 0.17-7
- New patch for bz#431766 to resolve conflicts

* Thu Feb  7 2008 Steve Conklin <sconklin@redhat.com> - 0.17-6
- Various fixes to follow upstream
- Resolves bz#431765 The example configuration file is invalid
- Resolves bz#431766 The netlabelctl command fails to run due to newer libnl package
- Resolves bz#431767 The url listed in the netlabel_tools package is wrong

* Mon Oct 16 2006 James Antill <james@and.org> - 0.17-3
- Add upstream patch.
- s/p1/p0/ for upstream patch.

* Sat Oct 14 2006 Steve Grubb <sgrubb@redhat.com> - 0.17-3
- Add init scripts and default rules

* Sun Oct  1 2006 James Antill <james@and.org> - 0.17-2
- Upgrade to latest upstream.

* Tue Aug 29 2006 James Antill <james@and.org> - 0.16-5
- Fix install calls for mock.

* Tue Aug 29 2006 James Antill <james@and.org> - 0.16-4
- Fix more reviewing problems, building on newer kernel-headers.
- Add URL tag.

* Fri Aug 18 2006 James Antill <james@and.org> - 0.16-3
- Fix minor review problems.
- Added BuildRequires for kernel headers (netlink).

* Fri Aug 18 2006 James Antill <james@and.org> - 0.16-2
- Use root as owner.
- Contribute to fedora extras.

* Thu Aug  3 2006 Paul Moore <paul.moore@hp.com> 0.16-1
- Bumped version number.

* Thu Jul  6 2006 Paul Moore <paul.moore@hp.com> 0.15-1
- Bumped version number.

* Mon Jun 26 2006 Paul Moore <paul.moore@hp.com> 0.14-1
- Bumped version number.
- Changes related to including the version number in the path name.
- Changed the netlabelctl perms from 0750 to 0755.
- Removed the patch. (included in the base with edits)
- Updated the description.

* Fri Jun 23 2006 Steve Grubb <sgrubb@redhat.com> 0.13-1
- Initial build.

