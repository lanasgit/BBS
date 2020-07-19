<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>

<%@ page import="javax.sql.DataSource" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>

<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="java.io.File" %>
<%
	request.setCharacterEncoding("utf-8");

	String uploadPath = "C:/Users/KIM/git/repository/BBS/WebContent/upload";
	int maxFileSize = 1024 * 1024 * 5; //5MB
	String encType = "utf-8";
	
	MultipartRequest multi = new MultipartRequest(request, uploadPath, maxFileSize, encType, new DefaultFileRenamePolicy());

	String cpage = multi.getParameter("cpage");
	String seq = multi.getParameter("seq");
	String subject = multi.getParameter("subject");
	String password = multi.getParameter("password");
	String content = multi.getParameter("content");
	String emot = multi.getParameter("emot").substring(4,6);
	String mail = "";
	if (!multi.getParameter("mail1").equals("") && !multi.getParameter("mail2").equals("")) {
		mail = multi.getParameter("mail1") + "@" + multi.getParameter("mail2");
	}
	String newFilename = multi.getFilesystemName("upload");
	long newFilesize = 0;
	File newFile = multi.getFile("upload");
	if (newFile != null) {
		newFilesize = newFile.length();
	}

	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	//성공, 실패 표현
	int flag = 2;
	
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup("java:comp/env");
		DataSource dataSource = (DataSource)envCtx.lookup("jdbc/mariadb1");
		
		conn = dataSource.getConnection();
		
		String sql = "select filename from board1 where seq=?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, seq);
		
		rs = pstmt.executeQuery();
		String filename = null;
		if (rs.next()) {
			filename = rs.getString("filename");
		}
		if (newFilename != null) {
			sql = "update board1 set subject=?, mail=?, content=?, emot=?, filename=?, filesize=? where seq=? and password=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, subject);
			pstmt.setString(2, mail);
			pstmt.setString(3, content);
			pstmt.setString(4, emot);
			pstmt.setString(5, newFilename);
			pstmt.setLong(6, newFilesize);
			pstmt.setString(7, seq);
			pstmt.setString(8, password);
		} else {
			sql = "update board1 set subject=?, mail=?, content=?, emot=? where seq=? and password=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, subject);
			pstmt.setString(2, mail);
			pstmt.setString(3, content);
			pstmt.setString(4, emot);
			pstmt.setString(5, seq);
			pstmt.setString(6, password);			
		}
		int result = pstmt.executeUpdate();
		if (result == 0) {
			//비밀번호를 잘못 기입
			flag = 1;
		} else if (result == 1) {
			//정상
			flag = 0;
			if(newFilename != null && filename != null) {
				File file = new File("C:/Users/KIM/git/repository/BBS/WebContent/upload/" + filename);
				file.delete();
			}
		}
	} catch (NamingException e) {
		System.out.println("[에러] : " + e.getMessage());
	} catch (SQLException e) {
		System.out.println("[에러] : " + e.getMessage());
	} finally {
		if (pstmt != null) pstmt.close();
		if (conn != null) conn.close();
	}
	out.println("<script type='text/javascript'>");
	if (flag == 0) {
		out.println("alert('글이 수정되었습니다.');");
		out.println("location.href='./board_view1.jsp?cpage="+cpage+"&seq="+seq+"';");
	} else if (flag == 1) {
		out.println("alert('비밀번호가 잘못되었습니다.');");
		out.println("history.back();");
	} else {
		out.println("alert('글수정을 실패했습니다.');");
		out.println("history.back();");
	}
	out.println("</script>");
%>