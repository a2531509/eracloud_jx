<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<script type="text/javascript">
    var $viewgrid;
    $(function(){
        $viewgrid = createDataGrid({
            id:"dgview",
            url:"cardInfoCount/cardInfoCountAction!querySBFeeCountList.action?bankId=${param.bankId}&applyBatchNo=${param.applyBatchNo}",
            queryParams:{queryType:"0"},
            border:false,
            fit:true,
            fitColumns:true,
            border:false,
            scrollbarSize:0,
            singleSelect:true,
            pageList:[100, 200, 500, 1000, 2000, 5000],
            columns:[[
                {field:'ID',checkbox:true},
                {field:"APPLY_ID",title:"申领编号",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"CERT_NO",title:"身份证号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"APPLY_TYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"COST_FEE",title:"补换卡金额",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"BANK_ID",title:"银行编号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"BANK_CARD_NO",title:"银行卡号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"APPLY_BATCH_NO",title:"申请时间",sortable:true,width:parseInt($(this).width() * 0.08)}
            ]],toolbar:'#taskviewconts'
        });
    });

    function query(){
        $viewgrid.datagrid("load",{
            queryType:"0",
            certNo:$("#certNo").val(),
            cardNo:$("#cardNo").val()
        });
    }



</script>
<n:layout>
    <n:center layoutOptions="border:false">
        <div id="taskviewconts">
            <table class="tablegrid">
                <tr>
                    <td class="tableleft">身份证号：</td>
                    <td class="tableright"><input id="certNo" name="certNo" type="text" class="textinput" maxlength="32"/></td>
                    <td class="tableleft">卡号：</td>
                    <td class="tableright"><input id="cardNo" name="cardNo" type="text" class="textinput" maxlength="32"/></td>
                </tr>
                <tr>
                    <td class="tableright">
                        <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
                    </td>
                </tr>
            </table>
        </div>
        <table id="dgview"></table>
    </n:center>
</n:layout>