<%--
  Created by IntelliJ IDEA.
  User: yangn
  Date: 2016-09-12
  Time: 10:54:35
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<n:layout cssStyle="border:none" cssClass="datagrid-toolbar">
    <n:center cssStyle="border:none">
        <div id="importDiv" style="text-align:center;" class="datagrid-toolbar">
            <div style="text-align:center;width:60%;margin:0 auto;">
                <table style="width:60% auto;" class="tablegrid">
                    <tr>
                        <td align="center"><input id="importFile" type="file" accept=".xls,.xlsx" style="width:100%"></td>
                        <td align="center">
                            <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" onclick="saveImportData()">上传</a>
                        </td>
                    </tr>
                    <tr style="height:30px;">
                        <td align="left" style="vertical-align:bottom;"><a href="javascript:void(0)" onclick="downloadTemplate();">金融市民卡导入申领模板下载</a></td>
                        <td align="center">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </n:center>
</n:layout>